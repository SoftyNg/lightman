import 'package:firebase_auth/firebase_auth.dart';
import '../models/register_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Register user with email and password
  Future<UserCredential> registerWithEmail(RegisterModel user) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await userCredential.user
          ?.updateDisplayName('${user.firstName} ${user.lastName}');

      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('An error occurred during registration');
    }
  }

  // ✅ Login user if email is verified
  Future<UserCredential> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.reload();
      final isVerified = userCredential.user?.emailVerified ?? false;

      if (!isVerified) {
        await _auth.signOut();
        throw Exception('Your email is not verified. Please check your inbox.');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('An error occurred during login');
    }
  }

  // ✅ Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw Exception('An error occurred during password reset');
    }
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ✅ Get current user
  User? get currentUser => _auth.currentUser;

  // ✅ Check if email is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }
}
