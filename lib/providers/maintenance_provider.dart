import 'dart:io';

import 'package:flutter/material.dart';
import '../services/firebase_maintenance.dart';
import 'dart:async';

class MaintenanceProvider extends ChangeNotifier {
  final MaintenanceService _service = MaintenanceService();

 List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> get reports => _reports;

  StreamSubscription? _sub;

  Future<void> createReport({
    required String deviceId,
    required String deviceName,
    required String serialNo,
    required String userId,
    required String userName,
    required String status,
    required String note,
    File? imageFile,
    String? location,
  }) async {

    await _service.createReportAndUpdateDevice(
      deviceId: deviceId,
      deviceName: deviceName,
      serialNo: serialNo,
      userId: userId,
      userName: userName,
      status: status,
      note: note,
      imageFile: imageFile,
      
    );

  }

 void listenUserReports(String userId) {
    _sub?.cancel();

    _sub = _service.getUserReports(userId).listen((data) {
      _reports = data;
      notifyListeners();
    });
  }

  void listenAllReports() {
    _sub?.cancel();

    _sub = _service.getAllReports().listen((data) {
      _reports = data;
      notifyListeners();
    });
  }

  void clear() {
    _sub?.cancel();
    _reports = [];
    notifyListeners();
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }



}