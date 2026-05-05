import 'package:flutter/material.dart';
import 'admin/page_admin.dart';
import 'personel/page_personel.dart';
import '../providers/user_provider.dart';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();





  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<UserProvider, bool>((p) => p.isLoading,);
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                filled:true,
                fillColor:Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Şifre",
                filled:true,
                fillColor:Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

         SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:  isLoading ? null : login,
            child:  isLoading
            ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Giriş Yap"),
           ),
          )
          
          ],
        ),
      ),
    );
  }

Future<void> login() async {
 final userProvider = Provider.of<UserProvider>(context, listen: false);
 bool success = await userProvider.login(
    emailController.text.trim(),
    passwordController.text.trim(),
  );
  
  if (!mounted) return;

  if (success) {
    if (userProvider.rol == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } 
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonelPage()),
      );
    }
  } 
  else {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Giriş başarısız")),
    );
  }
}

}