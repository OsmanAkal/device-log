import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/widget_filter_bar.dart';
import '../../providers/filter_bar_provider.dart';

class UserCrud extends StatefulWidget {
  const UserCrud({super.key});

  @override
  State<UserCrud> createState() => _UserCrudState();
}

class _UserCrudState extends State<UserCrud> {

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<UserProvider>().startListeningUsers();
  });
}

  @override
  Widget build(BuildContext context) {
  final users = context.watch<UserProvider>().users;
  final isLoading = context.watch<UserProvider>().usersLoading; 
 
  final filter = context.watch<FilterProvider>();

  final filtered = filter.filterAndSort(

  data: users,
  statusField: (r) => r["rol"],
  dateField: (r) {final ts = r["createdAt"];if (ts == null) return DateTime.now();return (ts as Timestamp).toDate();},
  searchMatch: (r, search) {

    final date = (r["createdAt"] as Timestamp).toDate();
    final dateStr = "${date.day}.${date.month}.${date.year}";

    final isDateSearch = search.contains(".");

    return (r["name"] ?? "")
            .toString()
            .toLowerCase()
            .contains(search) ||
        (r["username"] ?? "")
            .toString()
            .toLowerCase()
            .contains(search) ||
        (r["email"] ?? "")
            .toString()
            .toLowerCase()
            .contains(search) ||
        (isDateSearch && dateStr.contains(search));
  },
);

    return Scaffold(
  backgroundColor: Colors.white,
    body: isLoading
  ? const Center(child: CircularProgressIndicator())
  : SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: Colors.white),
            child: const FilterBar(statusOptions: ["hepsi", "admin", "personel"]),
          ),
          Expanded(
             child: users.isEmpty
              ? const Center(child: Text("Kullanıcı yok"))
              : filtered.isEmpty
              ? const Center(child: Text("Sonuç bulunamadı"))
              :ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        tileColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Icon(
                          user["rol"] == "admin"
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: user["rol"] == "admin"
                              ? Colors.amber
                              : Colors.white,
                        ),
                        title: Text(
                          "${user["name"]} ${user["surname"]}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          user["email"],
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => showUserDetail(user),
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
                onPressed: showCreateUserDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Kullanıcı Ekle", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }


  void showUserDetail(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Kullanıcı Detayı"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(" Ad: ${user["name"]}"),
            const SizedBox(height: 8),
            Text(" Soyad: ${user["surname"]}"),
            const SizedBox(height: 8),
            Text(" Email: ${user["email"]}"),
            const SizedBox(height: 8),
            Text(" Rol: ${user["rol"]}"),
          ],
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showUpdateDialog(user);
            },
            child: const Text("Güncelle"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context); // detay dialogu kapat
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
                  Navigator.pop(context); // confirm dialogu kapat
                  deleteUser(user["uid"]);
                  },
                child: const Text("Sil"),
                ),
              ],
              ),
            );
          },
        child: const Text("Sil"),
        ),

        ],
      ),
    );
  }

  void showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    String rol = "personel";

   showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text("Kullanıcı Ekle"),

    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Ad"),
          ),
          TextField(
            controller: surnameController,
            decoration: const InputDecoration(labelText: "Soyad"),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "Şifre"),
            obscureText: true,
          ),

          StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: rol,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "admin", child: Text("Admin")),
                  DropdownMenuItem(value: "personel", child: Text("Personel")),
                ],
                onChanged: (value) {
                  setState(() {
                    rol = value!;
                  });
                },
              );
            },
          ),
        ],
      ),
    ),

    actions: [
      TextButton(
        onPressed: () async {
            if (nameController.text.trim().isEmpty ||
                surnameController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty ||
                passwordController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tüm alanları doldurun")),
                );
              return;
              }
            final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
            if (!emailRegex.hasMatch(emailController.text.trim())) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Geçerli bir email girin")),
              );
            return;
            }
            if (passwordController.text.trim().length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Şifre en az 6 karakter olmalı")),
              );
            return;
            }
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
          final success = await context.read<UserProvider>().createUser(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            name: nameController.text.trim(),
            surname: surnameController.text.trim(),
            rol: rol,
          );

          if (!mounted) return;
          navigator.pop();

           if (!success) {
            messenger.showSnackBar(
            const SnackBar(content: Text("Kullanıcı oluşturulamadı")),
            );
            }
        },
        child: const Text("Kaydet"),
      ),
    ],
  ),
);
  }


  void showUpdateDialog(Map<String, dynamic> user) {
   
    final nameController =TextEditingController(text: user["name"]);
    final surnameController =TextEditingController(text: user["surname"]);
    String rol = user["rol"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Güncelle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Ad"),
            ),
            TextField(  
              controller: surnameController,
              decoration: const InputDecoration(labelText: "Soyad"),
            ),

            StatefulBuilder(
              builder: (context, setState) {
              return DropdownButton<String>(
              value: rol,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "admin", child: Text("Admin")),
                DropdownMenuItem(value: "personel", child: Text("Personel")),
                ],
                onChanged: (value) {
                  setState(() {
                   rol = value!;
                  });
                },
              );
             },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async{
              final navigator = Navigator.of(context);
              await context.read<UserProvider>().updateUser(
              user["uid"],
              {
               "name": nameController.text,
               "surname": surnameController.text,
               "rol": rol,
              },
              );

            if (!mounted) return;

            navigator.pop();
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }


  void deleteUser(String uid) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<UserProvider>().deleteUser(uid);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text("Kullanıcı silindi")),
      );
  }
}