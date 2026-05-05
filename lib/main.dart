import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/auth_gate.dart';
import 'providers/user_provider.dart';
import 'providers/device_provider.dart';
import 'providers/maintenance_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
    providers: [
     ChangeNotifierProvider(create: (_) => UserProvider()..checkLogin()),
     ChangeNotifierProvider(create: (_) => DeviceProvider()),
     ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
    
    ],
    child: const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthGate(),
    ),
    );
  }
}