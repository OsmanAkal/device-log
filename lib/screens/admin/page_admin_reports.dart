import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/maintenance_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widget_report_dialog.dart';
import '../../widgets/widget_filter_bar.dart';
import '../../providers/filter_bar_provider.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {


 @override
  void initState() {
  super.initState();

  Future.microtask(() {
    context.read<MaintenanceProvider>().listenAllReports();
  });
  
}

  @override
  Widget build(BuildContext context) {
  final reports = context.watch<MaintenanceProvider>().reports;

  final filter = context.watch<FilterProvider>();

  final filtered = filter.filterAndSort(

  data: reports,
  statusField: (r) => r["status"],
  dateField: (r) =>(r["createdAt"] as Timestamp).toDate(),
  searchMatch: (r, search) {

    final date = (r["createdAt"] as Timestamp).toDate();
    final dateStr = "${date.day}.${date.month}.${date.year}";

    final isDateSearch = search.contains(".");

    return (r["deviceName"] ?? "")
            .toString()
            .toLowerCase()
            .contains(search) ||
        (r["userName"] ?? "")
            .toString()
            .toLowerCase()
            .contains(search) ||
        (isDateSearch && dateStr.contains(search));
  },
);

    return Scaffold(
      backgroundColor: Colors.white,
      body: reports.isEmpty
          ? const Center(child: Text("Kayıt yok"))
          : Column(
          children: [
            Container(
            
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            child: const FilterBar(statusOptions: ["hepsi","çalışıyor","arızalı","eksik",],),),
          Expanded(
            child:ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final data = filtered[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  
                  child: ListTile(
                    horizontalTitleGap: 12,
                    minLeadingWidth: 80,
                    tileColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    leading: SizedBox(
                  width: 80,
                  height: 40,
                  child: Center(
                  child: Container(
                    alignment: Alignment.center, 
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor(data["status"]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  child: Text(
                  data["status"] ?? "",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

                    title: Text(
                      data["deviceName"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      "${data["userName"] ?? ""} • ${formatDate(data["createdAt"])}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => showReportDialog(context,data),
                  ),
                );
              },
            ),
          )
            ],
            )
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
      return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}";
    } catch (_) {
      return "";
    }
  }
}