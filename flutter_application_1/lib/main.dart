import 'package:flutter/material.dart';
import 'cots/design_system/styles.dart';
import 'cots/presentation/pages/dashboard_page.dart';
import 'cots/presentation/pages/list_task_page.dart';
// import 'cots/presentation/pages/detail_task_page.dart'; // Tidak perlu di-import di sini karena tidak masuk routes map
import 'cots/presentation/pages/add_task_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COTS PPB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto', 
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/list': (context) => const ListTaskPage(),
        '/add': (context) => const AddTaskPage(),
        
        // HAPUS route '/detail' dari sini.
        // Kita tidak bisa mendefinisikannya di sini karena DetailTaskPage butuh data 'task'.
        // Kita sudah menanganinya dengan Navigator.push di dashboard_page.dart & list_task_page.dart.
      },
    );
  }
}