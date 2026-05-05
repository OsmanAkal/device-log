import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import 'page_maintenance.dart';
import '../../widgets/widget_device_dialog.dart';
import '../../widgets/widget_filter_bar.dart';
import '../../providers/filter_bar_provider.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
     if (!mounted) return;
    context.read<DeviceProvider>().startListening();
  });
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
bool showMaintenance = false;
Map<String, dynamic>? selectedDevice;

@override
Widget build(BuildContext context) {


  return Scaffold(
    backgroundColor: Colors.white,
    body: showMaintenance
        ? MaintenancePage(
            device: selectedDevice!,
            onBack: () {
              setState(() {
                showMaintenance = false;
                selectedDevice = null;
              });
            },
          )
        : buildInventoryList(),
  );
}
          
  Widget buildInventoryList() {
     final devices = context.watch<DeviceProvider>().devices;
    final filter = context.watch<FilterProvider>();

    final filtered = filter.filterAndSort(
    data: devices,

    statusField: (d) => d["status"],

    dateField: (d) =>(d["createdAt"] as Timestamp).toDate(),

    searchMatch: (d, search) {
      return (d["name"] ?? "")
              .toString()
              .toLowerCase()
              .contains(search) ||
          (d["location"] ?? "")
              .toString()
              .toLowerCase()
              .contains(search) ||
          (d["serialNo"] ?? "")
              .toString()
              .toLowerCase()
              .contains(search) ||
          (d["type"] ?? "")
              .toString()
              .toLowerCase()
              .contains(search);
    },
  );
    return Scaffold(
    body:  SafeArea( 
        child:Column(
      children: [ 
       Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            child: const FilterBar(statusOptions: ["hepsi","çalışıyor","arızalı","eksik",],),),
    Expanded(
      child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final device = filtered [index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      horizontalTitleGap: 12,
                      minLeadingWidth: 80,
                      tileColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                       leading: SizedBox(
                        width: 80,
                        height: 40,
                        child: Center(
                        child: Container(
                          alignment: Alignment.center, 
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: getStatusColor(device["status"]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        child: Text(
                        device["status"] ?? "",
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
                        device["name"] ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Seri No: ${device["serialNo"]}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Konum: ${device["location"]}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
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
   ],),),);
  }

 
  
}