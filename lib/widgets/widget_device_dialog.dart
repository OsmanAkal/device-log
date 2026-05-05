import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showDeviceDetailDialog({
  required BuildContext context,
  required Map<String, dynamic> device,


  VoidCallback? onStartMaintenance, 
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Cihaz Detayı"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Cihaz: ${device["name"] ?? ""}"),
          const SizedBox(height: 6),

          Text("Seri No: ${device["serialNo"] ?? ""}"),
          const SizedBox(height: 6),

          Text("Tip: ${device["type"] ?? ""}"),
          const SizedBox(height: 6),

          Text("Konum: ${device["location"] ?? ""}"),
          const SizedBox(height: 6),

          Text("Durum: ${device["status"] ?? ""}"),
          const SizedBox(height: 6),

          Text("Son İşlem: ${formatDate(device["lastMaintenance"])}"),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Kapat"),
        ),

        // 🔥 SADECE varsa göster
        if (onStartMaintenance != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStartMaintenance();
            },
            child: const Text("Durum Kontrolü Başlat"),
          ),
      ],
    ),
  );
   
}
String formatDate(dynamic timestamp) {
  if (timestamp == null) return "";

  try {
    final date = (timestamp as Timestamp).toDate();

    String twoDigit(int n) => n.toString().padLeft(2, '0');

    return "${twoDigit(date.day)}.${twoDigit(date.month)}.${date.year} "
           "${twoDigit(date.hour)}:${twoDigit(date.minute)}";
  } 
  catch (e) {
    return "";
  }
}