import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chethanafm/viewmodels/chat_viewmodel.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/viewmodels/radio_viewmodel.dart';
import 'package:chethanafm/widgets/player/equalizer_animation_widget.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class ChatConversationView extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> otherUser;

  const ChatConversationView({
    super.key,
    required this.roomId,
    required this.otherUser,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _isTypingLocal = false;

  @override
  void initState() {
    super.initState();
    _markRead();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _typingTimer?.cancel();
    _updateTypingStatus(false);
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _scrollToBottom();
      _markRead();
    }
  }

  void _markRead() {
    final currentUserId = context.read<AuthViewModel>().userId.toString();
    context.read<ChatViewModel>().markAsRead(widget.roomId, currentUserId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTypingLocal) {
      _updateTypingStatus(true);
    } else if (text.isEmpty && _isTypingLocal) {
      _updateTypingStatus(false);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isTypingLocal) {
        _updateTypingStatus(false);
      }
    });
  }

  void _updateTypingStatus(bool typing) {
    if (_isTypingLocal == typing) return;
    _isTypingLocal = typing;
    final currentUserId = context.read<AuthViewModel>().userId.toString();
    context.read<ChatViewModel>().setTypingStatus(widget.roomId, currentUserId, typing);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authViewModel = context.read<AuthViewModel>();
    final chatViewModel = context.read<ChatViewModel>();
    final currentUserId = authViewModel.userId.toString();
    final otherUserId = widget.otherUser['userId'] as String? ?? '';

    chatViewModel.sendMessage(
      widget.roomId,
      currentUserId,
      otherUserId,
      text,
      senderName: authViewModel.name,
    );

    _messageController.clear();
    _updateTypingStatus(false);
    _scrollToBottom();
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return '';
    }
    
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year && now.month == date.month && now.day == date.day) {
      return "Today";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == date.year && yesterday.month == date.month && yesterday.day == date.day) {
      return "Yesterday";
    }
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final daysDiff = now.difference(date).inDays;
    if (daysDiff >= 0 && daysDiff < 7) {
      return weekdays[date.weekday - 1];
    }
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Color _getAvatarColor(String name) {
    final hash = name.hashCode;
    final colors = [
      Colors.redAccent, Colors.blueAccent, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo
    ];
    return colors[hash % colors.length];
  }



  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: 80.h,
        left: 20.w,
        child: _backgroundCircle(24.w),
      ),
      Positioned(
        top: 150.h,
        right: 40.w,
        child: _backgroundCircle(16.w),
      ),
      Positioned(
        top: 300.h,
        left: 60.w,
        child: _backgroundCircle(12.w),
      ),
      Positioned(
        top: 450.h,
        right: 80.w,
        child: _backgroundCircle(20.w),
      ),
      Positioned(
        bottom: 120.h,
        left: 30.w,
        child: _backgroundCircle(18.w),
      ),
      Positioned(
        bottom: 220.h,
        right: 20.w,
        child: _backgroundCircle(28.w),
      ),
    ];
  }

  Widget _backgroundCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        shape: BoxShape.circle,
      ),
    );
  }

  List<Widget> _buildAppbarBackgroundPatterns() {
    return [
      Positioned(
        top: -20.h,
        left: -20.w,
        child: Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: -40.h,
        right: -30.w,
        child: Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top: 20.h,
        right: 40.w,
        child: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = context.watch<ChatViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final radioViewModel = context.watch<RadioViewModel>();
    final currentUserId = authViewModel.userId.toString();
    
    final programTitle = radioViewModel.liveProgram?.title ?? "Midnight Pulse";
    final programRj = radioViewModel.liveProgram?.rj ?? "DJ Shane Martinez";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 190.h,
              pinned: true,
              backgroundColor: const Color(0xFF070F22),
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top + 10;
                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: isCollapsed
                        ? Text(
                            programTitle,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          )
                        : null,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF070F22), // Very dark navy
                            Color(0xFF0F2B5C), // Accent dark blue
                            Color(0xFF1DA1D8), // FM Cyan Blue
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._buildAppbarBackgroundPatterns(),
                          Positioned(
                            bottom: 16.h,
                            left: 16.w,
                            right: 16.w,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const PulsatingDot(),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "LIVE STREAMING",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFCA5A5),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  programTitle,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "with $programRj",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF93C5FD),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  width: 140.w,
                                  height: 36.h,
                                  child: AnimatedWaveform(
                                    isPlaying: radioViewModel.isPlaying,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            // Background circles/dots patterns
            ..._buildBackgroundCircles(),
            // Main content
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: chatViewModel.getMessages(widget.roomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        final error = snapshot.error.toString();
                        final isChannelError = error.contains("Unable to establish connection") || error.contains("channel-error");
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40.w),
                                SizedBox(height: 12.h),
                                Text(
                                  isChannelError
                                      ? "Firebase connection error. Please perform a cold restart (stop the running app and run it again from scratch) to rebuild native plugins."
                                      : "Error loading messages: $error",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(color: Colors.red, fontSize: 13.sp),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF1DA1D8)));
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 40.w, color: const Color(0xFF94A3B8)),
                              SizedBox(height: 12.h),
                              Text(
                                "No messages yet",
                                style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Say hello to start the conversation!",
                                style: GoogleFonts.outfit(fontSize: 12.sp, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final senderId = data['senderId'] as String? ?? '';
                          final text = data['text'] as String? ?? '';
                          final timestamp = data['timestamp'];
                          final isMe = senderId == currentUserId;

                          DateTime messageDate;
                          if (timestamp is Timestamp) {
                            messageDate = timestamp.toDate();
                          } else if (timestamp is int) {
                            messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
                          } else {
                            messageDate = DateTime.now();
                          }

                          // Check if we should render a date separator header
                          bool showDateSeparator = false;
                          if (index == 0) {
                            showDateSeparator = true;
                          } else {
                            final prevData = docs[index - 1].data();
                            final prevTimestamp = prevData['timestamp'];
                            DateTime prevDate;
                            if (prevTimestamp is Timestamp) {
                              prevDate = prevTimestamp.toDate();
                            } else if (prevTimestamp is int) {
                              prevDate = DateTime.fromMillisecondsSinceEpoch(prevTimestamp);
                            } else {
                              prevDate = DateTime.now();
                            }

                            if (messageDate.year != prevDate.year ||
                                messageDate.month != prevDate.month ||
                                messageDate.day != prevDate.day) {
                              showDateSeparator = true;
                            }
                          }

                          final senderName = data['senderName'] as String? ?? 'User';

                          final messageBubble = Container(
                            margin: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 16.r,
                                    backgroundColor: _getAvatarColor(senderName),
                                    child: Text(
                                      senderName.isNotEmpty ? senderName[0].toUpperCase() : "?",
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe) 
                                        Padding(
                                          padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                                          child: Text(
                                            senderName,
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: isMe ? AppColors.secondaryColor : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.r),
                                            topRight: Radius.circular(20.r),
                                            bottomLeft: isMe ? Radius.circular(20.r) : Radius.circular(4.r),
                                            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(20.r),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          text,
                                          style: GoogleFonts.outfit(
                                            color: isMe ? Colors.white : Colors.black87,
                                            fontSize: 14.sp,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: isMe ? 0 : 4.w,
                                          right: isMe ? 4.w : 0,
                                        ),
                                        child: Text(
                                          _formatMessageTime(timestamp),
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (showDateSeparator) {
                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 16.h),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB).withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    _formatDateHeader(messageDate).toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                messageBubble,
                              ],
                            );
                          }

                          return messageBubble;
                        },
                      );
                    },
                  ),
                ),

                // Message Input Field
                SafeArea(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF9CA3AF)),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black),
                            decoration: InputDecoration(
                              hintText: "Type message...",
                              hintStyle: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontSize: 13.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                            onChanged: _onTextChanged,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: Color(0xFF9CA3AF)),
                          onPressed: () {},
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PulsatingDot extends StatefulWidget {
  const PulsatingDot({super.key});

  @override
  State<PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<PulsatingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(_animation.value * 0.6),
                blurRadius: 6 * _animation.value,
                spreadRadius: 3 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
