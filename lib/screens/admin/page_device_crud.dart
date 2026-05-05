
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/widget_device_dialog.dart';
import '../../widgets/widget_filter_bar.dart';
import '../../providers/filter_bar_provider.dart';

class DeviceCrud extends StatefulWidget {
  const DeviceCrud({super.key});

  @override
  State<DeviceCrud> createState() => _DeviceCrudState();
}

class _DeviceCrudState extends State<DeviceCrud> {

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  Widget build(BuildContext context) {

    
    final devices = context.watch<DeviceProvider>().devices;
    final filter = context.watch<FilterProvider>();

    final filtered = filter.filterAndSort(
    data: devices,

    statusField: (d) => d["status"],

    dateField: (d) {final ts = d["createdAt"];if (ts == null) return DateTime.now();return (ts as Timestamp).toDate();},

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
      backgroundColor: Colors.white,
      body:SafeArea(
            child:Column(
            children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            child: const FilterBar(statusOptions: ["hepsi","çalışıyor","arızalı","eksik",],),),

            Expanded(
              child: devices.isEmpty
                ? const Center(child: CircularProgressIndicator()) 
                : filtered.isEmpty
                ? const Center(child: Text("Sonuç bulunamadı"))
                : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                  final device = filtered[index];

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
                        device["name"],
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

                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Emin misin?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Vazgeç"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<DeviceProvider>().deleteDevice(device["id"]);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Sil"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () => showDeviceDetailDialog(
                        context: context,
                        device: device,
                        ),
                      
                    ),
                  );
                },
                
              ),
          ),
          Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: showCreateDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Cihaz Ekle", style: TextStyle(color: Colors.white)),
                ),
                ),
                ),
            ],
          ),),
     
 

    );
  }

  void showCreateDialog() {
    final nameController = TextEditingController();
    final serialController = TextEditingController();
    final typeController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cihaz Ekle"),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Ad"),
              ),
              TextField(
                controller: serialController,
                decoration: const InputDecoration(labelText: "Seri No"),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Tip"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Konum"),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () async {
               if (nameController.text.trim().isEmpty ||
                  serialController.text.trim().isEmpty ||
                  typeController.text.trim().isEmpty ||
                  locationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tüm alanları doldurun")),
                  );
                return;
              }
              final success =  await context.read<DeviceProvider>().createDevice(
                name: nameController.text.trim(),
                serialNo: serialController.text.trim(),
                type: typeController.text.trim(),
                location: locationController.text.trim(),
              );

               if (!context.mounted) return;
                Navigator.pop(context);

               if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Cihaz oluşturulamadı")),
                  );
                 }
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }
}