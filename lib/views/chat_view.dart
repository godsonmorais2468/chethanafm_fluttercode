import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/viewmodels/home_viewmodel.dart';
import 'package:chethanafm/views/auth_dialogs.dart';
import 'package:chethanafm/views/chat_conversation_view.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchLiveProgram();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();

    if (!authViewModel.isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: _buildLoggedOutPlaceholder(context),
      );
    }

    if (homeViewModel.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F4F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DA1D8)),
        ),
      );
    }

    final liveProgram = homeViewModel.liveProgram;
    final isLive = liveProgram != null && liveProgram.isLive;

    if (!isLive) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.speaker_notes_off_outlined,
                  size: 64.w,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(height: 24.h),
                Text(
                  "No live broadcast is currently available.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Live chat will open automatically when a live show starts.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChatConversationView(
      roomId: "live_show_${liveProgram.id}",
      otherUser: {
        'name': liveProgram.title,
        'userId': "live_show_${liveProgram.id}",
        'isLiveChat': true,
        'rj': liveProgram.rj,
      },
    );
  }

  Widget _buildLoggedOutPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1DA1D8).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF1DA1D8),
                size: 48.w,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Sign In to Chat",
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Join our community of listeners and chat with your favorite RJs and online friends in real-time.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => triggerLoginDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DA1D8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                elevation: 0,
              ),
              child: Text(
                "Sign In Now",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
