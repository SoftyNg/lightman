import 'package:firebase_auth/firebase_auth.dart';
import '../models/register_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Register user with email and password, and send email verification
  Future<UserCredential> registerWithEmail(RegisterModel user) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // Update display name (optional)
      await userCredential.user
          ?.updateDisplayName('${user.firstName} ${user.lastName}');

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('An error occurred during registration');
    }
  }

  // ✅ Login user with email and password, only if email is verified
  Future<UserCredential> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload to fetch latest email verification status
      await userCredential.user?.reload();
      final isVerified = userCredential.user?.emailVerified ?? false;

      if (!isVerified) {
        await _auth.signOut(); // Sign out unverified user
        throw Exception('Your email is not verified. Please check your inbox.');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('An error occurred during login');
    }
  }

  // ✅ Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ✅ Get current user
  User? get currentUser => _auth.currentUser;

  // ✅ Check if user's email is verified (optional utility)
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload(); // Refresh user data
    return user?.emailVerified ?? false;
  }
}
