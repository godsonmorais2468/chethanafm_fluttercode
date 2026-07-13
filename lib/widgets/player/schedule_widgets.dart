import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class ScheduleLoadingWidget extends StatelessWidget {
  const ScheduleLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF1DA1D8),
      ),
    );
  }
}

class ScheduleErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ScheduleErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48.w,
          ),
          SizedBox(height: 12.h),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 16.sp, color: Colors.white),
            label: Text(
              "Retry",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleEmptyWidget extends StatelessWidget {
  final String message;

  const ScheduleEmptyWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: Colors.grey.shade400,
              size: 48.w,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
