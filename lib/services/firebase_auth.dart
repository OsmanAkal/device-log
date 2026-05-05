import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? currentUser() {
  return FirebaseAuth.instance.currentUser;
}

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("Auth hata: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}