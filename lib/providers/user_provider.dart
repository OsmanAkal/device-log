import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/firebase_auth.dart';
import '../services/firebase_user.dart';

class UserProvider extends ChangeNotifier {

  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseUserService _userService = FirebaseUserService();


  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _usersLoading = false;
  StreamSubscription? _sub;

  // GETTERLAR
  User? get firebaseUser => _firebaseUser;
  Map<String, dynamic>? get userData => _userData;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  bool get usersLoading => _usersLoading;
  String? get userId => _firebaseUser?.uid;


  String get rol => _userData?["rol"] ?? "";
  
///
Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);

      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _firebaseUser = user;

      final data = await _userService.getUser(user.uid);

      if (data == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _userData = data;
      _users = [];
      _isLoading = false;
      notifyListeners();

      return true;

    } catch (e) {
      print("Provider login hata: $e");

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

///
Future<void> checkLogin() async {
  _isLoading = true;
  notifyListeners();

  final user = _authService.currentUser(); 

  if (user == null) {
    _isLoading = false;
    notifyListeners();
    return;
  }

  _firebaseUser = user;

  final data = await _userService.getUser(user.uid);

  if (data == null) {
    await logout();
    return;
  }
  _userData = data;

  _isLoading = false;
  notifyListeners();
}
///


void startListeningUsers() {
  _usersLoading = true;
  notifyListeners();

  _sub?.cancel();

  _sub = _userService.getUsersStream().listen(
    (snapshot) {
      _users = snapshot.docs.map((doc) {
        return {
          "uid": doc.id,
          ...doc.data(),
        };
      }).toList();

      _usersLoading = false;
      notifyListeners();
    },
    onError: (e) {
      print("stream error: $e");
      _usersLoading = false;
      notifyListeners();
    },
  );
}
///
Future<void> logout() async {
    await _authService.logout();

    _firebaseUser = null;
    _userData = null;
    _users = [];
    _isLoading = false;
    _sub?.cancel();
    notifyListeners();
  }
///
Future<bool> createUser({
  required String email,
  required String password,
  required String name,
  required String surname,
  required String rol,
}) async {
  try {
    await _userService.createUserWithAuth(
      email: email,
      password: password,
      name: name,
      surname: surname,
      rol: rol,
    );
    return true;

  }  
  on FirebaseAuthException catch (e) {
    print("FirebaseAuth hata: ${e.code} - ${e.message}");
    return false;
    }
    catch (e) {
     print("createUser hata: $e");
    return false;
  }
}

///
Future<void> updateUser(String uid, Map<String, dynamic> data) async {
  try {
    await _userService.updateUser(uid, data);
  } 
  catch (e) {
    print("update hata: $e");
  }
}

///
Future<void> deleteUser(String uid) async {
  try {
    await _userService.deleteUser(uid);
   
  } 
  catch (e) {
    print("delete hata: $e");
  }
}

@override
void dispose() {
  _sub?.cancel();
  super.dispose();
}

}
