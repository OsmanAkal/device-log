import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDeviceService {
  final _db = FirebaseFirestore.instance;

  Future<void> createDevice({
  required String name,
  required String serialNo,
  required String type,
  required String location,
  }) async {
    await _db.collection("Inventory").add({
      "name": name,
      "serialNo": serialNo,
      "type": type,
      "location": location,
      "status": "çalışıyor",
      "lastMaintenance": null,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDevicesStream() {
  return _db
      .collection("Inventory")
      .orderBy("createdAt", descending: true)
      .snapshots();
}

  Future<void> deleteDevice(String id) async {
    await _db.collection("Inventory").doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final snap = await _db.collection("Inventory").get();

    return snap.docs.map((e) {
      return {
        "id": e.id,
        ...e.data(),
      };
    }).toList();
  }
  
}