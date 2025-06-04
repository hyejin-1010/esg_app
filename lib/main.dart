import 'package:esg_app/screens/find_new_password.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';

import 'screens/find_password.dart';
import 'screens/home.dart';
import 'screens/join.dart';
import 'screens/login.dart';
import 'screens/start_screen.dart';
import 'screens/mypage.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ShadcnApp(
      title: '가칭',
      theme: ThemeData(colorScheme: ColorSchemes.lightGreen(), radius: 0.5),
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
        colorScheme: material.ColorScheme.light(primary: Color(0xFF34C759)),
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
          name: '/mypage',
          page: () => MyPageScreen(initialTab: 0),
        ),
      ],
    );
  }
}
