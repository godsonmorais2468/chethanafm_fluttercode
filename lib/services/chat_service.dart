import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of users for search
  Stream<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId) {
    if (query.trim().isEmpty) {
      return Stream.value([]);
    }
    return _firestore.collection('users')
        .snapshots()
        .map((snapshot) {
          final users = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final name = (data['name'] as String? ?? '').toLowerCase();
            final phone = (data['phoneNumber'] as String? ?? '').toLowerCase();
            final userId = data['userId']?.toString() ?? doc.id;
            
            if (userId != currentUserId && (name.contains(query.toLowerCase()) || phone.contains(query.toLowerCase()))) {
              data['userId'] = userId; // Ensure userId is populated in the returned map
              users.add(data);
            }
          }
          return users;
        });
  }

  // Stream of chat rooms for a user
  Stream<List<Map<String, dynamic>>> getChatRooms(String currentUserId) {
    return _firestore.collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          debugPrint("getChatRooms: Found ${snapshot.docs.length} rooms for $currentUserId");
          final rooms = snapshot.docs.map((doc) {
            final data = doc.data();
            data['roomId'] = doc.id;
            debugPrint("getChatRooms room ${doc.id} participants: ${data['participants']}");
            return data;
          }).toList();

          rooms.sort((a, b) {
            final aTime = a['updatedAt'] as Timestamp?;
            final bTime = b['updatedAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          return rooms;
        });
  }

  // Get other participant detail stream
  Stream<Map<String, dynamic>?> getUserDetailStream(String userId, {String? currentUserId}) {
    if (userId.isEmpty) return Stream.value(null);

    return _firestore.collection('users').snapshots().map((snapshot) {
      Map<String, dynamic>? fallbackUser;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final currentDocUserId = data['userId']?.toString() ?? doc.id;
        
        // Save the first other user as a fallback in case we are dealing with a corrupted 'null' room
        if (currentUserId != null && currentDocUserId != currentUserId) {
          fallbackUser ??= {...data, 'userId': currentDocUserId};
        }

        if (currentDocUserId == userId) {
          data['userId'] = currentDocUserId;
          return data;
        }
      }
      
      // If we couldn't find the user by ID (e.g. corrupted 'null' ID), but we have a fallback user, use it!
      if (userId == "null" && fallbackUser != null) {
        return fallbackUser;
      }

      return null;
    });
  }

  // Stream of messages for a room
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String roomId) {
    return _firestore.collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Create chat room if it doesn't exist and return roomId
  Future<String> getOrCreateChatRoom(String currentUserId, String otherUserId) async {
    final participants = [currentUserId, otherUserId]..sort();
    final roomId = participants.join('_');

    final roomDoc = await _firestore.collection('chat_rooms').doc(roomId).get();
    if (!roomDoc.exists) {
      await _firestore.collection('chat_rooms').doc(roomId).set({
        'roomId': roomId,
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return roomId;
  }

  // Join Live Chat room
  Future<String> joinLiveChat(String showId) async {
    final roomId = "live_show_$showId";
    final roomDoc = await _firestore.collection('chat_rooms').doc(roomId).get();
    
    if (!roomDoc.exists) {
      await _firestore.collection('chat_rooms').doc(roomId).set({
        'roomId': roomId,
        'isLiveChat': true,
        'showId': showId,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return roomId;
  }


  // Send message
  Future<void> sendMessage(String roomId, String senderId, String receiverId, String text, {String? senderName, String? profileImage}) async {
    if (text.trim().isEmpty) return;

    final messageDoc = _firestore.collection('chat_rooms').doc(roomId).collection('messages').doc();
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      transaction.set(messageDoc, {
        'messageId': messageDoc.id,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp,
        'isRead': false,
        if (senderName != null) 'senderName': senderName,
        if (profileImage != null) 'profileImage': profileImage,
      });

      transaction.update(_firestore.collection('chat_rooms').doc(roomId), {
        'lastMessage': text,
        'lastMessageTime': timestamp,
        'updatedAt': timestamp,
      });
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String currentUserId) async {
    final unreadQuery = await _firestore.collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadQuery.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Stream of unread messages count for a specific room
  Stream<int> getUnreadCount(String roomId, String currentUserId) {
    return _firestore.collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Set typing indicator
  Future<void> setTypingStatus(String roomId, String userId, bool isTyping) async {
    await _firestore.collection('chat_rooms').doc(roomId).set({
      'typingStatus': {
        userId: isTyping,
      }
    }, SetOptions(merge: true));
  }

  // Stream typing status of other user
  Stream<bool> getTypingStatus(String roomId, String otherUserId) {
    return _firestore.collection('chat_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          final data = doc.data();
          if (data == null) return false;
          final typing = data['typingStatus'] as Map<String, dynamic>?;
          return typing?[otherUserId] as bool? ?? false;
        });
  }
}
