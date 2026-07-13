import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    String formattedPhone = phoneNumber.trim();
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+91$formattedPhone';
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }
}
