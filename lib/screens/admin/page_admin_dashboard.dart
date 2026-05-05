import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../widgets/widget_report_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/widget_maintenance_mini_list.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeviceProvider>().startListening();
      context.read<MaintenanceProvider>().listenAllReports();
      
    });
  }

  @override
  Widget build(BuildContext context) {
 
   final devices = context.watch<DeviceProvider>().devices;
    final reports = context.watch<MaintenanceProvider>().reports;
    int okCount = devices.where((d) => d["status"] == "çalışıyor").length;
    int errorCount = devices.where((d) => d["status"] == "arızalı").length;
    int missingCount = devices.where((d) => d["status"] == "eksik").length;

bool isToday(Timestamp? ts) {
  if (ts == null) return false;

  final date = ts.toDate();
  final now = DateTime.now();

  return date.day == now.day &&
         date.month == now.month &&
         date.year == now.year;
}
int todayReports =reports.where((r) => isToday(r["createdAt"])).length;
int todayErrors =reports.where((r) => isToday(r["createdAt"]) && r["status"] == "arızalı").length;
int todayOk =reports.where((r) => isToday(r["createdAt"]) && r["status"] == "çalışıyor").length;
int todayMiss =reports.where((r) => isToday(r["createdAt"]) && r["status"] == "eksik").length;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
          child: Column(
            children: [

              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildPieChart(okCount, errorCount, missingCount),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStat("Çalışan", okCount, Colors.green),
                            const SizedBox(height: 8),
                            _buildStat("Arızalı", errorCount, Colors.red),
                            const SizedBox(height: 8),
                            _buildStat("Eksik", missingCount, Colors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                color: Colors.indigo.shade200,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text("Bugün Yapılan İşlemler",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                 ),
                  Row(
                  children: [
                  _miniCard("Toplam", todayReports, Colors.blue),
                   const SizedBox(width: 8),

                  _miniCard("Çalışan", todayOk, Colors.green),
                   const SizedBox(width: 8),

                  _miniCard("Arızalı", todayErrors, Colors.red),
                  const SizedBox(width: 8),

                   _miniCard("Eksik", todayMiss, Colors.orange),
                   const SizedBox(width: 8),
                  ],
                ),
                  ],
                   
                ),
              ),


             Expanded(
              flex:2, 
              child: ReportListWidget(
                reports: reports,
                onTap: (data) => showReportDialog(context, data),
              ),
            )
          
            ]
          ),
        ),
      );
    
    
  }

 
  Widget _buildPieChart(int ok, int error, int missing) {
    return PieChart(
      PieChartData(
        sectionsSpace: 1,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: ok.toDouble(),
            color: Colors.green,
            title: "$ok",
          ),
          PieChartSectionData(
            value: error.toDouble(),
            color: Colors.red,
            title: "$error",
          ),
          PieChartSectionData(
            value: missing.toDouble(),
            color: Colors.orange,
            title: "$missing",
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, int value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text("$value",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
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
  Widget _miniCard(String title, int value, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "$value",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return "";

    try {
      final date = (timestamp as Timestamp).toDate();
      String two(int n) => n.toString().padLeft(2, '0');

      return "${two(date.day)}.${two(date.month)}.${date.year} "
          "${two(date.hour)}:${two(date.minute)}";
    } catch (e) {
      return "";
    }
  }
  
}