import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'page_login.dart';
import 'admin/page_admin.dart';
import 'personel/page_personel.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userProvider.firebaseUser == null) {
      return const LoginPage();
    }

    if (userProvider.rol == "admin") {
      return const AdminPage();
    } 
    else {
      return const PersonelPage();
    }
  }
}