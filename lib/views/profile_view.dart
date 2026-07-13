import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/views/about_view.dart';
import 'package:chethanafm/views/terms_view.dart';
import 'package:chethanafm/views/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  void _showLogoutConfirmationDialog(BuildContext parentContext, AuthViewModel authVM) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top icon with sparkles
                SizedBox(
                  width: 80.w,
                  height: 80.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sparkle top-left
                      Positioned(
                        top: 10.h,
                        left: 8.w,
                        child: Icon(Icons.star, color: const Color(0xFFDBEAFE), size: 10.w),
                      ),
                      // Sparkle top-right
                      Positioned(
                        top: 18.h,
                        right: 12.w,
                        child: Icon(Icons.star, color: const Color(0xFFDBEAFE), size: 8.w),
                      ),
                      // Circle bottom-left
                      Positioned(
                        bottom: 20.h,
                        left: 12.w,
                        child: Container(
                          width: 5.w, 
                          height: 5.w, 
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
                          ),
                        ),
                      ),
                      // Main icon background
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.logout_rounded,
                            color: const Color(0xFF2563EB),
                            size: 26.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Log out?",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "You're about to sign out of your account.\nYou can log back in anytime using your\nphone number and password.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF64748B),
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 20.h),
                // Info Box
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.gpp_good_outlined,
                          color: const Color(0xFF2563EB),
                          size: 16.w,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your account and data will remain safe.",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5.sp,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Logging out only ends your current\nsession on this device.",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF64748B),
                                fontSize: 11.sp,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 20.h),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final rootNavigator = Navigator.of(parentContext, rootNavigator: true);
                          Navigator.of(dialogContext).pop();
                          await authVM.logout();
                          rootNavigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginView()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.white, size: 16.w),
                            SizedBox(width: 6.w),
                            Text(
                              "Log Out",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
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
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthViewModel authVM) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Change Password",
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      authVM.changePassword(
                        oldPasswordController.text,
                        newPasswordController.text,
                        (success, msg) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DA1D8),
                    ),
                    child: Text(
                      "Change Password",
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileSheet(BuildContext context, AuthViewModel authVM) {
    final nameController = TextEditingController(text: authVM.name);
    final phoneController = TextEditingController(text: authVM.phone);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Profile Information",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    authVM.updateProfile(
                      nameController.text.trim(),
                      phoneController.text.trim(),
                      (success) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile updated successfully!")),
                          );
                        }
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DA1D8),
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isRed ? Colors.red.withOpacity(0.08) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: isRed ? Colors.red : const Color(0xFF64748B),
            size: 20.w,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            color: isRed ? Colors.red : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isRed ? Colors.red.withOpacity(0.6) : const Color(0xFF94A3B8),
          size: 20.sp,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220.h,
            pinned: true,
            backgroundColor: const Color(0xFF0B2C7A),
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: Text(
              "Profile",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1DA1D8), Color(0xFF0B2C7A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Avatar Stack inside flexible space
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: Colors.white,
                            child: Text(
                              authViewModel.name.isNotEmpty ? authViewModel.name[0].toUpperCase() : '?',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1DA1D8),
                                fontWeight: FontWeight.bold,
                                fontSize: 38.sp,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showEditProfileSheet(context, authViewModel),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DA1D8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 16.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    authViewModel.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${authViewModel.currentUser?.countryCode ?? ''} ${authViewModel.phone}".trim(),
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Profile Options Tiles List
                  _buildProfileTile(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsView()),
                      );
                    },
                  ),
                  _buildProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: "About Us",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutView()),
                      );
                    },
                  ),
                  _buildProfileTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    isRed: true,
                    onTap: () => _showLogoutConfirmationDialog(context, authViewModel),
                  ),
                  
                  // Extra padding to clear floating nav row
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
