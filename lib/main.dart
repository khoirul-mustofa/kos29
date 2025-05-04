import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://lnhdhgvokxpmbhgdvxtq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxuaGRoZ3Zva3hwbWJoZ2R2eHRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNTA0NzAsImV4cCI6MjA2MTkyNjQ3MH0.HfhcBM7gq_sGPS38qtXt0THGXrr2tjgdPDAIucZsS5k',
  );

  runApp(
    GetMaterialApp(
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      title: "Indikost",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
