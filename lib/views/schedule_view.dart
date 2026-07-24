import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chethanafm/utils/images.dart';
import 'package:chethanafm/viewmodels/schedule_viewmodel.dart';
import 'package:chethanafm/viewmodels/radio_viewmodel.dart';
import 'package:chethanafm/views/dashboard_view.dart';
import 'package:chethanafm/models/program_schedule.dart';
import 'package:chethanafm/widgets/player/schedule_widgets.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with SingleTickerProviderStateMixin {
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  // Pulsing animation controller for the LIVE badge
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // Pulsing glow for live card
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Automatically select today's day of week
    final today = DateFormat('E').format(DateTime.now()); // "Mon", "Tue", etc.
    final todayIndex = _days.indexOf(today);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleVM = context.read<ScheduleViewModel>();
      if (todayIndex != -1 && _days.contains(today)) {
        scheduleVM.selectDay(today);
      }
      scheduleVM.fetchSchedule(); // fetch dynamic schedule API
    });
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
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
        await context.read<ScheduleViewModel>().refreshSchedule();
      } catch (e) {
        debugPrint("ScheduleView refresh error: $e");
      } finally {
        _isRefreshing = false;
      }
    });
  }




  /// Format "HH:mm:ss" → "h:mm AM/PM".
  String _fmt(String t) {
    try {
      return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(t));
    } catch (_) {
      return t;
    }
  }

  /// Is this schedule item currently on air? Only meaningful when selectedDay == today.
  bool _isOnAir(ProgramSchedule s, String selectedDay) {
    return context.read<ScheduleViewModel>().isOnAir(s, selectedDay);
  }

  Widget _buildAppbarBackgroundPatterns() {
    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              right: -50.w,
              top: -50.w,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              left: -30.w,
              bottom: -40.w,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: 60.w,
              bottom: 20.h,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleViewModel = context.watch<ScheduleViewModel>();
    final radioViewModel = context.watch<RadioViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.h,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF070F22),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  DashboardView.of(context)?.changeTab(0);
                },
              ),
              title: Text(
                "Schedule",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              centerTitle: true,
              actions: [
                // Day picker dropdown
                PopupMenuButton<String>(
                  onSelected: (day) {
                    scheduleViewModel.selectDay(day);
                  },
                  offset: const Offset(0, 40),
                  itemBuilder: (context) {
                    return _days.map((day) {
                      final isSelected =
                          day.toLowerCase() == scheduleViewModel.selectedDay.toLowerCase();
                      return PopupMenuItem(
                        value: day,
                        child: Text(
                          day,
                          style: GoogleFonts.outfit(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF1DA1D8)
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          scheduleViewModel.selectedDay.toLowerCase() ==
                                  DateFormat('E').format(DateTime.now()).toLowerCase()
                              ? "Today"
                              : scheduleViewModel.selectedDay,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF070F22), Color(0xFF0F2B5C), Color(0xFF1DA1D8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    _buildAppbarBackgroundPatterns(),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w, top: 40.h, right: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10.h),
                            Text(
                              "Program Schedule",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Discover what's on air right now and what's coming up next.",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13.sp,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Builder(
          builder: (context) {
            if (scheduleViewModel.isLoading) {
              return const ScheduleLoadingWidget();
            }
  
            if (scheduleViewModel.errorMessage.isNotEmpty) {
              return ScheduleErrorWidget(
                errorMessage: scheduleViewModel.errorMessage,
                onRetry: () => scheduleViewModel.fetchSchedule(),
              );
            }
  
            final dayPrograms = scheduleViewModel
                .getProgramListForDay(scheduleViewModel.selectedDay);
  
            if (dayPrograms.isEmpty) {
              return ScheduleEmptyWidget(
                message:
                    "No programmes scheduled for ${scheduleViewModel.selectedDay}.\nCheck back later!",
              );
            }
  
          // We don't split into live and other to keep chronological order.
          final combined = dayPrograms;
  
            return ListView.builder(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              physics: const BouncingScrollPhysics(),
              itemCount: combined.length,
              itemBuilder: (context, index) {
                final prog = combined[index];
                final isLive =
                    _isOnAir(prog, scheduleViewModel.selectedDay);
  
                return _buildProgramCard(
                  context,
                  prog: prog,
                  isLive: isLive,
                  radioViewModel: radioViewModel,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgramCard(
    BuildContext context, {
    required ProgramSchedule prog,
    required bool isLive,
    required RadioViewModel radioViewModel,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: isLive
                ? Border.all(
                    color: const Color(0xFF1DA1D8)
                        .withValues(alpha: 0.5 * _pulseAnimation.value + 0.15),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isLive
                    ? const Color(0xFF1DA1D8).withValues(
                        alpha: 0.12 * _pulseAnimation.value)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: isLive ? 20 : 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
      },
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Cyan left accent line for live item
            if (isLive)
              Container(
                width: 4.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF1DA1D8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Program thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            Images.qboxCube,
                            width: 50.w,
                            height: 50.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Title + RJ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prog.title,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                              if (prog.rj.trim().isNotEmpty && prog.rj.trim() != '.') ...[
                                SizedBox(height: 2.h),
                                Text(
                                  prog.rj,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Time on top right corner
                        Text(
                          "${_fmt(prog.startTime)} - ${_fmt(prog.endTime)}",
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (isLive) ...[
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pulsing LIVE badge
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, _) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1DA1D8)
                                      .withValues(
                                          alpha: 0.10 +
                                              0.08 *
                                                  _pulseAnimation.value),
                                  borderRadius:
                                      BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5.w,
                                      height: 5.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF1DA1D8)
                                            .withValues(
                                                alpha:
                                                    _pulseAnimation.value),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "LIVE",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF1DA1D8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () => radioViewModel.togglePlay(),
                            child: CircleAvatar(
                              radius: 12.r,
                              backgroundColor: const Color(0xFF1DA1D8)
                                  .withValues(alpha: 0.15),
                              child: Icon(
                                radioViewModel.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: const Color(0xFF1DA1D8),
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
