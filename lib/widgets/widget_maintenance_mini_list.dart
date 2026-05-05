
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';




  class ReportListWidget extends StatelessWidget {
  final List reports;
  final Function(Map<String, dynamic>) onTap;

  const ReportListWidget({
    super.key,
    required this.reports,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12), 
      decoration: BoxDecoration( 
        color: Colors.indigo.shade200, 
        borderRadius: BorderRadius.circular(16), ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Durum Kontrol Kayıtları",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final r = reports[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: ListTile(
                  leading: Icon(
                    r["status"] == "arızalı"
                        ? Icons.warning
                        : r["status"] == "eksik"
                            ? Icons.remove_circle
                            : Icons.check_circle,
                    color: r["status"] == "arızalı"
                        ? Colors.red
                        : r["status"] == "eksik"
                            ? Colors.orange
                            : Colors.green,
                  ),

                  title: Text(r["deviceName"] ?? ""),

                  subtitle: Text( "${r["status"]} • ${formatDate(r["createdAt"])}", ),

                  trailing: r["imageUrl"] != null
                      ? const Icon(Icons.image, size: 18)
                      : null,

                  onTap: () => onTap(r),
                ),
              );
            },
          ),
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
  } catch (e) {
    return "";
  }
}
}