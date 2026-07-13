import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/views/home_view.dart';
import 'package:chethanafm/views/schedule_view.dart';
import 'package:chethanafm/views/chat_view.dart';
import 'package:chethanafm/views/profile_view.dart';

import 'package:chethanafm/viewmodels/radio_viewmodel.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => DashboardViewState();

  static DashboardViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<DashboardViewState>();
  }
}

class DashboardViewState extends State<DashboardView> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _views = [
    const HomeView(),
    const ScheduleView(),
    const ChatView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
    } else {
      _updateOnlineStatus(false);
    }

    if (state == AppLifecycleState.detached) {
      try {
        final radioViewModel = context.read<RadioViewModel>();
        radioViewModel.stop();
        radioViewModel.disposePlayer();
      } catch (e) {
        debugPrint("Error cleaning up player on detach: $e");
      }
    }
  }

  void _updateOnlineStatus(bool isOnline) {
    try {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.isLoggedIn) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(authViewModel.userId.toString())
            .set({
          'online': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).catchError((e) {
          debugPrint("Firestore online update error: $e");
        });
      }
    } catch (e) {
      debugPrint("AuthViewModel read error in lifecycle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final radioViewModel = context.watch<RadioViewModel>();

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1DA1D8),
                      Color(0xFF0B2C7A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chethana 90.8",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Voice of the Community",
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded, color: Color(0xFF1DA1D8)),
                title: Text("Home", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  changeTab(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cell_tower_rounded, color: Color(0xFF1DA1D8)),
                title: Text("Shows", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  changeTab(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1DA1D8)),
                title: Text("Chat", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  changeTab(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF1DA1D8)),
                title: Text("Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  changeTab(3);
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main Content View
          Positioned.fill(
            child: PageTransitionSwitcher(
              index: _selectedIndex,
              children: _views,
            ),
          ),
          
          // Floating Bottom Row containing capsule navigation bar & circular play button
          Positioned(
            left: 8.w,
            right: 8.w,
            bottom: 20.h,
            child: Row(
              children: [
                // Capsule Bottom Navigation
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_rounded, "Home"),
                        _buildNavItem(1, Icons.cell_tower_rounded, "Shows"),
                        _buildNavItem(2, Icons.chat_bubble_outline_rounded, "Chat"),
                        _buildNavItem(3, Icons.person_outline_rounded, "Profile"),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Circular Play Button
                GestureDetector(
                  onTap: () => radioViewModel.togglePlay(),
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1DA1D8),
                          Color(0xFF0B2C7A),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1DA1D8).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: radioViewModel.isBuffering
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              radioViewModel.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26.w,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final activeColor = const Color(0xFF1DA1D8);
    final inactiveColor = const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom simple page transitions switcher
class PageTransitionSwitcher extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const PageTransitionSwitcher({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: SizedBox(
        key: ValueKey<int>(index),
        child: children[index],
      ),
    );
  }
}
