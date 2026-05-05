import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';


class MaintenanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Future<void> createReportAndUpdateDevice({
    required String deviceId,
    required String deviceName,
    required String serialNo,

    required String userId,
    required String userName,

    required String status,
    required String note,
    File? imageFile,
  }) async {

    final batch = _db.batch();
    final logRef = _db.collection("MaintenanceLogs").doc();
    final deviceRef = _db.collection("Inventory").doc(deviceId);
    final deviceSnap = await deviceRef.get();
    final deviceData = deviceSnap.data() as Map<String, dynamic>;

    String? imageUrl;
    if (status == "arızalı" && imageFile != null) {
      imageUrl = await uploadImage(imageFile,userId, deviceId);
    }

    batch.set(logRef, {
      "deviceId": deviceId,
      "deviceName": deviceName,
      "serialNo": serialNo,

      "userId": userId,
      "userName": userName,

      "status": status,
      "note": note,
      if (imageUrl != null) "imageUrl": imageUrl,
      "location": deviceData["location"],

      "createdAt": FieldValue.serverTimestamp(),
    });

    batch.set(deviceRef,{"status": status,"lastMaintenance": FieldValue.serverTimestamp(),},

  SetOptions(merge: true),
);

    await batch.commit();
  }


Stream<List<Map<String, dynamic>>> getUserReports(String userId) {

    return _db
        .collection('MaintenanceLogs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

 Stream<List<Map<String, dynamic>>> getAllReports() {
    return _db
        .collection("MaintenanceLogs")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

Future<String?> uploadImage(File image, String userId, String deviceId) async {
  try {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final compressedFile = await _compressImage(image);
    final fileToUpload = compressedFile ?? image;

    final ref = FirebaseStorage.instance
        .ref()
        .child('Maintenance')
        .child(deviceId)
        .child(userId)
        .child('$fileName.jpg');

    await ref.putFile(fileToUpload);

    final url = await ref.getDownloadURL();

    return url;
  } catch (e) {
    print("Upload error: $e");
    return null;
  }
}

Future<File?> _compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    file.absolute.path + "_compressed.jpg",
    quality: 60, // 🔥 kalite düşür → boyut düşer
    minWidth: 1024,
    minHeight: 1024,
  );

  return result != null ? File(result.path) : null;
}

    

}