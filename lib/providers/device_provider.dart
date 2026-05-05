import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_device.dart';

class DeviceProvider extends ChangeNotifier {
  final FirebaseDeviceService _service = FirebaseDeviceService();

  List<Map<String, dynamic>> _devices = [];


  StreamSubscription? _sub;

  List<Map<String, dynamic>> get devices => _devices;


  void startListening() {

    notifyListeners();

    _sub?.cancel();

    _sub = _service.getDevicesStream().listen((snapshot) {
      _devices = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data(),
        };
      }).toList();


      notifyListeners();
    });
  }

  Future<bool> createDevice({
    required String name,
    required String serialNo,
    required String type,
    required String location,
  }) async {
    try{   await _service.createDevice(
      name: name,
      serialNo: serialNo,
      type: type,
      location: location,
    );
    return true;
    }
    catch(e){
      print(e);
      return false;
    }
 
    
  }

  Future<void> deleteDevice(String id) async {
    await _service.deleteDevice(id);

  }

  Future<void> loadDevices() async {

  notifyListeners();

  try {
    _devices = await _service.getDevices();
  } catch (e) {
    print("error: $e");
  }


  notifyListeners();
}

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}