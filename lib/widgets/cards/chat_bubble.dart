import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  final String username;
  final String comment;
  final DateTime time;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.username,
    required this.comment,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      // Sent message (Right side)
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF5C83E7), // Beautiful soft blue matching mockup Image 3
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C83E7).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  comment,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.done_all_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 14.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Received message (Left side with avatar & sender details)
      final isHost = username.contains("RJ") || username.toLowerCase() == "host";
      
      // Determine avatar URL based on sender name
      String avatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150&auto=format&fit=crop"; // Default man avatar
      if (username == "Sarah M.") {
        avatarUrl = "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop"; // Sarah female avatar
      } else if (username == "RJ Shifin") {
        avatarUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop"; // RJ Shifin male avatar
      } else if (username.startsWith("Listener")) {
        avatarUrl = "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150&auto=format&fit=crop";
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar
            CircleAvatar(
              radius: 18.r,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            SizedBox(width: 10.w),
            // Message Content Card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name + potential HOST badge
                  Row(
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      if (isHost) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C83E7).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: const Text(
                            "HOST",
                            style: TextStyle(
                              color: Color(0xFF5C83E7),
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Chat Bubble box
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        topRight: Radius.circular(20.r),
                        bottomLeft: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1E293B),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
