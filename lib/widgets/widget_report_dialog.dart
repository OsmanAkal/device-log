import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showReportDialog(BuildContext context,Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Row(
          children: [
          Icon(Icons.build, color: getStatusColor(data["status"])),
          const SizedBox(width: 8),
          Text(data["deviceName"]),
            ],
          ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Durum: ${data["status"]}"),
              Text("Açıklama: ${data["note"]}"),
              Text("Kullanıcı: ${data["userName"]}"),
              Text("Seri No: ${data["serialNo"]}"),
              Text("Konum: ${data["location"]}"),
              Text("Tarih: ${formatDate(data["createdAt"])}"),

              const SizedBox(height: 12),

              if (data["imageUrl"] != null)
                GestureDetector(
                onTap: () {
                  showDialog(
                  context: context,
                  builder: (ctx) => Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(ctx).size.width * 0.9,
                      height: MediaQuery.of(ctx).size.height * 0.6,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InteractiveViewer(
                        child: Image.network(
                        data["imageUrl"],
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, error, stack) => // 🔴 hata durumu
                          const Center(child: Text("Resim yüklenemedi")),
                        ),
                      ),
                    ),
                  ),
                 ),
              );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox( // 🔴 double.infinity yerine SizedBox
                width: double.infinity,
                child: Image.network(
                  data["imageUrl"],
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) =>
                  const Center(child: Text("Resim yüklenemedi")),
                  loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                    return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
                ),
              )
              )
              else const Text("Fotoğraf yok"),
              ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          )
        ],
      );
    },
  );
  
}
 Color getStatusColor(String status) {
    switch (status) {
      case "çalışıyor":
        return Colors.green;
      case "eksik":
        return Colors.orange;
      case "arızalı":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  String formatDate(dynamic timestamp) {
  if (timestamp == null) return "";

  try {
    final date = (timestamp as Timestamp).toDate();

    String twoDigit(int n) => n.toString().padLeft(2, '0');

    return "${twoDigit(date.day)}.${twoDigit(date.month)}.${date.year} "
           "${twoDigit(date.hour)}:${twoDigit(date.minute)}";
  } catch (e) {
    return "";
  }
}