import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../page_login.dart';
import 'page_inventory.dart';
import 'page_user_reports.dart';
import 'page_dashboard.dart';
import '../../providers/filter_bar_provider.dart';
class PersonelPage extends StatefulWidget {
  const PersonelPage({super.key});

  @override
  State<PersonelPage> createState() => _PersonelPageState();
}

class _PersonelPageState extends State<PersonelPage> {
  late final List<Widget> pages;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    pages = [
      const DashboardPage(),
      ChangeNotifierProvider(
        create: (_) => FilterProvider(),
        child: const InventoryPage(),),
      ChangeNotifierProvider(
        create: (_) => FilterProvider(),
        child: const UserReportsPage(),)

    ];
  }

  final titles = [
    "Kontrol Paneli",
    "Envanter",
    "Durum Kontrol Kayıtları",
  ];

void selectPage(int index) {
  setState(() {
    selectedIndex = index;
  });

  Future.microtask(() {
    if (mounted) Navigator.pop(context);
  });
}

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

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
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person, color: Colors.white),
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
              accountName: Text("${userProvider.userData?["name"] ?? ""} ${userProvider.userData?["surname"] ?? ""}",),
              accountEmail: Text(userProvider.userData?["email"] ?? ""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.indigo),
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
              leading: const Icon(Icons.list),
              title: const Text("Raporlarım"),
              onTap: () => selectPage(2),
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

      body: pages[selectedIndex],
    );
  }
}