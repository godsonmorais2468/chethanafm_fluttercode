class Comment {
  final int id;
  final int userId;
  final String username; // Field for the user's name
  final String comment;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create an instance from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      username: json['user']?['name'] ?? "Unknown", // Extract 'name' from 'user', default to "Unknown"
      comment: json['comment'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Method to convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': {'name': username}, // Nest the username in the 'user' object
      'comment': comment,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
