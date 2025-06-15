import 'package:flutter/material.dart';
import 'package:mobile_sarpras/pages/login_page.dart';
import 'package:mobile_sarpras/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarpras App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder(
        future: getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.data != null) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
