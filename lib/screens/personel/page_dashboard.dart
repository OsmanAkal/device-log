import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_log/widgets/widget_device_dialog.dart';
import '../../providers/device_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/widget_maintenance_mini_list.dart';
import '../../widgets/widget_report_dialog.dart';
import 'page_maintenance.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = "çalışıyor";

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    context.read<DeviceProvider>().startListening();

    final userId = context.read<UserProvider>().userId;

    if (userId != null) {
      context.read<MaintenanceProvider>().listenUserReports(userId);
    }
  });
}

bool showMaintenance = false;
Map<String, dynamic>? selectedDevice;
  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DeviceProvider>().devices;
    final reports = context.watch<MaintenanceProvider>().reports;

    List filteredDevices = devices.where((d) {
  return (d["status"] ?? "") == selectedFilter;
}).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body:showMaintenance
          ? MaintenancePage(
              device: selectedDevice!,
               onBack: () {
                  setState(() {
                  showMaintenance = false;
                  selectedDevice = null;
                });
              },
            )
          : buildDeviceAndReportSection(
            filteredDevices: filteredDevices,
             reports: reports,
            ),
    );
  }

Widget buildDeviceAndReportSection({
  required List filteredDevices,
  required List reports,
}) {
  return SafeArea(
    child: Column(
      children: [

        const SizedBox(height: 10),

        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade200,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [

                // 🔥 FILTER ROW
                Row(
                  children: [
                    _filterButton("çalışıyor", "Çalışıyor"),
                    const SizedBox(width: 8),
                    _filterButton("arızalı", "Arızalı"),
                    const SizedBox(width: 8),
                    _filterButton("eksik", "Eksik"),
                  ],
                ),

                const SizedBox(height: 12),

         
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(device["name"] ?? ""),
                          subtitle: Text(
                            "Konum: ${device["location"]} • SN: ${device["serialNo"]}",
                          ),
                          onTap: () => showDeviceDetailDialog(
                            context: context,
                              device: device,
                            onStartMaintenance: () {
                            setState(() {
                            selectedDevice = device;
                            showMaintenance = true;
                            });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),


        Expanded(
          flex: 2,
          child: ReportListWidget(
            reports: reports,
            onTap: (data) => showReportDialog(context, data),
          ),
        )
      ],
    ),
  );
}

Widget _filterButton(String key, String text) {
  final isSelected = selectedFilter == key;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedFilter = key;
      });
    },
    child: Container(
      width: 100,
      height:40,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueGrey : Colors.grey.shade300,
        border: Border(
          bottom: BorderSide(
          color: isSelected ? Colors.blueGrey : Colors.transparent,
           width: 2,
          ),
),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
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
 


}