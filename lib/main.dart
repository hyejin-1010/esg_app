import 'package:esg_app/controllers/mission_controller.dart';
import 'package:esg_app/screens/home.dart';
import 'package:esg_app/screens/login.dart';
import 'package:esg_app/screens/register_mission.dart';
import 'package:flutter/material.dart' as material;
import 'package:esg_app/constant/color.dart';
import 'package:esg_app/screens/find_new_password.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:esg_app/controllers/feed_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/find_password.dart';
import 'screens/join.dart';
import 'screens/start_screen.dart';
import 'screens/mypage.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Get.put(FeedController());
  Get.put(MissionController());

  try {
    await Supabase.initialize(
      url: 'https://dzmhxwhowtjnioxjzzlb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6bWh4d2hvd3RqbmlveGp6emxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5MzQ4NTEsImV4cCI6MjA2NDUxMDg1MX0.KxnU9e6Hp61kYgbkBpnpvE7XtVMkKwdngT-6oPzgdbk',
    );
  } catch (error) {
    debugPrint('[ERROR] Supabase initialize error: $error');
  }

  runApp(
    ShadcnApp(
      title: '가칭',
      theme: ThemeData(
        colorScheme: ColorSchemes.lightGreen(),
        radius: 0.5,
        typography: Typography.geist(
          sans: TextStyle(fontFamily: 'NanumSquareNeo'),
        ),
      ),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: material.ThemeData(
        colorScheme: material.ColorScheme.light(primary: primaryColor),
        fontFamily: 'NanumSquareNeo',
        textTheme: material.TextTheme(
          titleLarge: material.TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: material.TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
          titleSmall: material.TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
          labelLarge: material.TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: material.TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: material.TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: material.TextStyle(fontSize: 16.0),
          bodyMedium: material.TextStyle(fontSize: 14.0),
          bodySmall: material.TextStyle(fontSize: 12.0),
        ),
      ),
      initialRoute: '/start',
      getPages: [
        GetPage(name: '/start', page: () => const StartScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/join', page: () => const JoinScreen()),
        GetPage(name: '/find/password', page: () => const FindPasswordScreen()),
        GetPage(
          name: '/find/new/password',
          page: () => const FindNewPasswordScreen(),
        ),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
          name: '/register-mission',
          page: () => const RegisterMissionScreen(),
        ),
        GetPage(
          name: '/mypage',
          page: () => MyPageScreen(initialTab: 0),
        ),
      ],
    );
  }
}
