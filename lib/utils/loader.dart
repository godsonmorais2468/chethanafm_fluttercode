import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100, // Set the desired height
        width: 100, // Set the desired width
        child: SpinKitCircle(color: AppColors.primaryColor),
      ),
    );
  }
}
