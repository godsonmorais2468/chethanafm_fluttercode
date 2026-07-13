import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class LiveRadioShimmer extends StatelessWidget {
  const LiveRadioShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                width: 70.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white.withOpacity(0.25),
            child: Container(
              width: 180.w,
              height: 30.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white.withOpacity(0.25),
            child: Container(
              width: 120.w,
              height: 15.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                width: 100.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LiveRadioError extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const LiveRadioError({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 40.w),
        SizedBox(height: 8.h),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh_rounded, size: 16.sp, color: AppColors.primaryColor),
          label: Text(
            "Try Again",
            style: GoogleFonts.outfit(
              color: AppColors.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
        ),
      ],
    );
  }
}

class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            "OFFLINE",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
