import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get currentUid {return FirebaseAuth.instance.currentUser?.uid ?? "";}
  
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _db.collection("Users").doc(uid).get();

      if (doc.exists) {
        return doc.data();
      }

      return null;
    } catch (e) {
      print("User fetch hata: $e");
      return null;
    }
  }

Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
  return _db
      .collection("Users")
      .where(FieldPath.documentId, isNotEqualTo: currentUid)
      .snapshots();
}


 Future<void> createUserWithAuth({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String rol,
  }) async {
  
    final secondaryApp = await Firebase.initializeApp(
      name: "SecondaryApp",
      options: Firebase.app().options,
    );
    try {

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

   
      final userCredential = await secondaryAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
     await _db.collection("Users").doc(uid).set({
        "email": email,
        "name": name,
        "surname": surname,
        "rol": rol,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
     });

  } 
  catch (e) {
  print("create user error: $e");
   rethrow;
  } 
  
  finally {
    await secondaryApp.delete();
  }

  }


  Future<void> updateUser(
  String uid,
  Map<String, dynamic> data,
) async {
  await _db.collection("Users").doc(uid).update({
    ...data,
    "updatedAt": FieldValue.serverTimestamp(),
  });
}

  Future<void> deleteUser(String uid) async {
    await _db.collection("Users").doc(uid).delete();
  }



}