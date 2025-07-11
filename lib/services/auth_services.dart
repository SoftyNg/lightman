import 'package:firebase_auth/firebase_auth.dart';
import '../models/register_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user with email and password
  Future<UserCredential> registerWithEmail(RegisterModel user) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // Optional: Update display name or other profile fields
      await userCredential.user
          ?.updateDisplayName('${user.firstName} ${user.lastName}');

      // Optional: You can store other details in Firestore here

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('An error occurred during registration');
    }
  }
}
