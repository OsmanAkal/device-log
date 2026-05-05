import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/maintenance_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MaintenancePage extends StatefulWidget {
  final Map<String, dynamic> device;
  final VoidCallback onBack;
  const MaintenancePage({super.key, required this.device,required this.onBack});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  String status = "çalışıyor";
  File? selectedImage;
  final picker = ImagePicker();
  final noteController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
  super.initState();
  
 
  status = widget.device["status"] ?? "çalışıyor";
}

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final maintenance = context.watch<MaintenanceProvider>();
    final userProvider = context.watch<UserProvider>();



    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
      widget.onBack();
    },
  child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
      child: SingleChildScrollView(
      child: Center(
      child: Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.indigo.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( device["name"] ?? "",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
                const SizedBox(height: 4),
                Text(" Seri No: ${device["serialNo"] ?? ""}"),
                const SizedBox(height: 4),
                Text(" Konum: ${device["location"] ?? ""}"),
              ],
            ),
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: "çalışıyor", child: Text("Çalışıyor")),
              DropdownMenuItem(value: "arızalı", child: Text("Arızalı")),
              DropdownMenuItem(value: "eksik", child: Text("Eksik")),
            ],
            onChanged: (val) => setState(() => status = val!),
            decoration: const InputDecoration(
              labelText: "Durum",
              filled: true,
              fillColor: Colors.white,
            ),
         
          ),

          const SizedBox(height: 18),

          TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Not",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white
            ),
          ),

          const SizedBox(height: 40),




  
        ElevatedButton(
          onPressed: isLoading ? null : () async {
            setState(() {
              isLoading = true;
            });

          try {
            if (status == "arızalı") {
            final picked = await picker.pickImage(source: ImageSource.camera);

            if (picked != null) {
              selectedImage = File(picked.path);
            }
            }

           if (status == "arızalı" && selectedImage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Arızalı cihaz için fotoğraf zorunlu")),
              );
            return;
            }
            if (noteController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Açıklama yazmak zorunludur")),
              );
            return;
            }

        await maintenance.createReport(
          deviceId: device["id"],
          deviceName: device["name"] ?? "",
          serialNo: device["serialNo"] ?? "",
          userId: userProvider.firebaseUser!.uid,
          userName: userProvider.userData?["name"] ?? "",
          status: status,
          note: noteController.text,
          imageFile: selectedImage,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rapor kaydedildi")),
        );

        setState(() {
          status = "çalışıyor";
          noteController.clear();
          selectedImage = null;
        });

        widget.onBack();

      } finally {
        setState(() {
          isLoading = false;
        });
    }
  },
          child: isLoading
           ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text("Yükleniyor..."),
        ],
      )
    : const Text("Rapor Oluştur"),
          ),

        
        ]
      ),
    ),
  ),
)
            ),
            
    ),
    );
  }
}