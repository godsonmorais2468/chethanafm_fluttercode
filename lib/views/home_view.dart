import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/widgets/player/animated_live_badge.dart';
import 'package:chethanafm/widgets/player/equalizer_animation_widget.dart';
import 'package:chethanafm/widgets/player/live_radio_widgets.dart';
import 'package:chethanafm/viewmodels/radio_viewmodel.dart';
import 'package:chethanafm/viewmodels/schedule_viewmodel.dart';
import 'package:chethanafm/viewmodels/home_viewmodel.dart';
import 'package:chethanafm/models/program_schedule.dart';
import 'package:chethanafm/models/live_program.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/images.dart';
import 'dashboard_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchLiveProgram();
      context.read<ScheduleViewModel>().fetchSchedule();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isRefreshing) return;
      _isRefreshing = true;
      try {
        await context.read<HomeViewModel>().refreshLiveProgram();
        if (!mounted) return;
        await context.read<RadioViewModel>().refreshLiveProgramSilent();
        if (!mounted) return;
        await context.read<ScheduleViewModel>().refreshSchedule();
      } catch (e) {
        debugPrint("HomeView refresh error: $e");
      } finally {
        _isRefreshing = false;
      }
    });
  }




  /// Format "HH:mm:ss" to "h:mm AM/PM" (e.g. "6:00 AM").
  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      int h = int.parse(parts[0]);
      final int m = int.parse(parts[1]);
      final String period = h >= 12 ? 'PM' : 'AM';
      if (h == 0) {
        h = 12;
      } else if (h > 12) {
        h -= 12;
      }
      return '$h:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radioViewModel = context.watch<RadioViewModel>();
    final scheduleViewModel = context.watch<ScheduleViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();

    final liveProgram = homeViewModel.liveProgram;

    final ProgramSchedule? nextShow = scheduleViewModel.nextUpcomingShow;
    final List<ProgramSchedule> remainingSchedules = scheduleViewModel.remainingUpcomingShows;

    final int minsUntilNext = scheduleViewModel.getMinutesUntilNextShow(nextShow);

    // Show badge only if ≤10 mins away
    final bool showNextBadge = minsUntilNext <= 10;

    final topImageHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Hero Section ──────────────────────────────────────────
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background Image
                Container(
                  width: double.infinity,
                  height: topImageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                    image: const DecorationImage(
                      image: AssetImage(Images.qboxCube),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Q BOX Live Card
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 10.h),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(32.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Builder(
                            builder: (context) {
                              if (homeViewModel.isLoading) {
                                return const LiveRadioShimmer();
                              }

                              if (homeViewModel.errorMessage != null) {
                                return LiveRadioError(
                                  errorMessage: homeViewModel.errorMessage!,
                                  onRetry: () {
                                    homeViewModel.fetchLiveProgram();
                                    radioViewModel.fetchLiveProgram();
                                  },
                                );
                              }

                              if (liveProgram == null) {
                                return _buildOfflineCard(context);
                              }

                              return _buildLiveCard(
                                context,
                                liveProgram: liveProgram,
                                radioViewModel: radioViewModel,
                                showNextBadge: showNextBadge,
                                minsUntilNext: minsUntilNext,
                                nextShow: nextShow,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Next On Air ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Next On Air",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1DA1D8),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildNextOnAirCard(context, nextShow),
            ),
            SizedBox(height: 24.h),

            // ── Today's Line-Up ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Line-Up",
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DashboardView.of(context)?.changeTab(1);
                    },
                    child: Text(
                      "View All >",
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1DA1D8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildTodayLineup(context, remainingSchedules),
            ),

            // Space for bottom floating navigation bar
            SizedBox(height: 110.h),
          ],
        ),
      ),
    );
  }

  // ── Card builders ────────────────────────────────────────────────────────

  Widget _buildOfflineCard(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            _buildChatButton(context, liveProgram: null),
          ],
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "No live programme available.",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Offline",
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildLiveCard(
    BuildContext context, {
    required LiveProgram liveProgram,
    required RadioViewModel radioViewModel,
    required bool showNextBadge,
    required int minsUntilNext,
    required ProgramSchedule? nextShow,
  }) {
    final radioViewModel2 = radioViewModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            liveProgram.isLive
                ? const LiveBadge(isPlaying: true)
                : const SizedBox.shrink(),
            _buildChatButton(context, liveProgram: liveProgram),
          ],
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            liveProgram.title,
            style: GoogleFonts.outfit(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            liveProgram.rj,
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (!liveProgram.isLive) ...[
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Tune in to our 24/7 automated music playlist.",
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: Colors.white60,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: radioViewModel2.isPlaying
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 35.h,
                                padding: EdgeInsets.only(right: 16.w),
                                child: const AnimatedWaveform(isPlaying: true),
                              ),
                              SizedBox(height: 12.h),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  // "Next in X Min" badge – only show if ≤10 minutes away
                  if (showNextBadge && nextShow != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8C00).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color:
                                  const Color(0xFFFF8C00).withOpacity(0.3)),
                        ),
                        child: Text(
                          "Next in $minsUntilNext Min",
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: const Color(0xFFFF8C00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await radioViewModel2.updateStreamUrl(
                  liveProgram.streamUrl,
                  title: liveProgram.title,
                  rj: liveProgram.rj,
                );
                radioViewModel2.togglePlay();
              },
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1DA1D8), Color(0xFF0B2C7A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: radioViewModel2.isBuffering
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          radioViewModel2.isPlaying
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
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, {LiveProgram? liveProgram}) {
    final isLiveChatAvailable = liveProgram != null && liveProgram.isLive;

    return GestureDetector(
      onTap: () {
        if (!isLiveChatAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Live chat is available only during live broadcasts.")),
          );
          return;
        }
        
        DashboardView.of(context)?.changeTab(2);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isLiveChatAvailable ? Colors.greenAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isLiveChatAvailable ? Colors.greenAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLiveChatAvailable) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent,
                      blurRadius: 3,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              "Live Chat",
              style: GoogleFonts.outfit(
                color: isLiveChatAvailable ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: isLiveChatAvailable ? Colors.white : Colors.white38,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextOnAirCard(BuildContext context, ProgramSchedule? nextShow) {
    if (nextShow == null) {
      // No upcoming show today
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF004D40),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004D40).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Icon(
              Icons.nightlight_round,
              color: Colors.white54,
              size: 32.w,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "That's a wrap for today!",
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "No more shows are scheduled for today. Tune in tomorrow for more great content!",
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: Colors.white60,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF004D40),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nextShow.title,
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  nextShow.rj,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "${_formatTime(nextShow.startTime)} - ${_formatTime(nextShow.endTime)}",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Microphone icon as thumbnail placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: 80.w,
              height: 80.w,
              color: Colors.white.withOpacity(0.08),
              child: Icon(
                Icons.mic_rounded,
                color: Colors.white30,
                size: 40.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLineup(
      BuildContext context, List<ProgramSchedule> remainingSchedules) {
    if (scheduleViewModel(context).isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: Color(0xFF1DA1D8)),
        ),
      );
    }

    if (remainingSchedules.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_rounded,
                color: Colors.grey.shade400,
                size: 40.w,
              ),
              SizedBox(height: 10.h),
              Text(
                "No more upcoming shows today.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Check the Schedule tab for full weekly listings.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayItems = remainingSchedules.take(3).toList();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: displayItems.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey.withOpacity(0.2),
        height: 24.h,
      ),
      itemBuilder: (context, index) {
        final s = displayItems[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1DA1D8).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.radio_rounded,
                color: const Color(0xFF1DA1D8),
                size: 28.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          s.rj,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      Text(
                        "${_formatTime(s.startTime)} - ${_formatTime(s.endTime)}",
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  ScheduleViewModel scheduleViewModel(BuildContext context) =>
      context.read<ScheduleViewModel>();
}
