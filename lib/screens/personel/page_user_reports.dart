import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/maintenance_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widget_report_dialog.dart';
import '../../widgets/widget_filter_bar.dart';
import '../../providers/filter_bar_provider.dart';
class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> {
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    final userId = context.read<UserProvider>().userId;

    if (userId != null) {
      context.read<MaintenanceProvider>().listenUserReports(userId);
    }
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
          ? const Center(child: Text("Rapor yok"))
          : Column(children: [
          Container(
            
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            child: const FilterBar(statusOptions: ["hepsi","çalışıyor","arızalı","eksik",],),),
          Expanded(
            child: ListView.builder(
              itemCount: filtered .length,
              itemBuilder: (context, index) {
                final data = filtered [index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                horizontalTitleGap: 12,
                minLeadingWidth: 80,
                tileColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                ),

                contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
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
                  formatDate(data["createdAt"]),
                  style: const TextStyle(color: Colors.white70),
                  ),

                 onTap: () => showReportDialog(context,data),
                ),
              );

              },
            ),
          )
    ],),
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

}