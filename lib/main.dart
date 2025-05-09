import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kos29/app/lang/translation.dart';
import 'package:kos29/app/style/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kos29/app/style/theme/theme_controller.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await Supabase.initialize(
    url: 'https://lnhdhgvokxpmbhgdvxtq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxuaGRoZ3Zva3hwbWJoZ2R2eHRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNTA0NzAsImV4cCI6MjA2MTkyNjQ3MH0.HfhcBM7gq_sGPS38qtXt0THGXrr2tjgdPDAIucZsS5k',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final hasSeenOnboarding = box.read('onboarding_seen') ?? false;
    return GetMaterialApp(
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: Get.deviceLocale ?? const Locale('id', 'ID'),
      fallbackLocale: Locale('en', 'US'),
      themeMode: themeController.theme,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      title: "Indikost",
      initialRoute: hasSeenOnboarding ? Routes.BOTTOM_NAV : Routes.ONBOARDING,
      getPages: AppPages.routes,
    );
  }
}
