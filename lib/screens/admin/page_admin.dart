import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../page_login.dart';
import 'page_users_crud.dart';
import 'page_device_crud.dart';
import 'page_admin_reports.dart';
import 'page_admin_dashboard.dart';
import '../../providers/filter_bar_provider.dart';

class AdminPage extends StatefulWidget{
   const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();

}
class _AdminPageState extends State<AdminPage>{
  late final List<Widget> pages;
 int selectedIndex = 0;
  @override
  void initState() {
    super.initState();

   pages = [
  const AdminDashboard(),
  ChangeNotifierProvider(
    create: (_) => FilterProvider(),
    child: const DeviceCrud(),
  ),
   ChangeNotifierProvider(
    create: (_) => FilterProvider(),
    child: const UserCrud(),
  ),
  ChangeNotifierProvider(
    create: (_) => FilterProvider(),
    child: const AdminReportsPage(),
  ),
];
}

  final titles = [
    "Kontrol Paneli",
    "Envanter",
    "Kullanıcı Yönetimi",
    "Durum Raporları",
  ];

    void selectPage(int index) {
  setState(() => selectedIndex = index);
  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
  final userProvider = context.watch<UserProvider>();
  return Scaffold(

  backgroundColor: Colors.white,
  appBar: AppBar(
    title: Text(
      titles[selectedIndex],
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.indigo,
    leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
    ),

     actions: const [
          
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.amber
              ),
          )
      ],
  ),

   drawer: Drawer(
        child: Column(
          children: [

             UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
              color: Colors.lightBlueAccent,
              ),
              accountName: Text(userProvider.userData?["name"] ?? ""),
              accountEmail: Text(userProvider.userData?["email"] ?? ""),
              currentAccountPicture:const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.amber
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Kontrol Paneli"),
              onTap: () => selectPage(0),
            ),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Envanter"),
              onTap: () => selectPage(1),
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Kullanıcı Yönetimi"),
              onTap: () => selectPage(2),
            ),

            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Durum Raporları"),
              onTap: () => selectPage(3),
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                final navigator = Navigator.of(context);
                await userProvider.logout();
                if (!mounted) return;
                
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),

     
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
  );
  }
}