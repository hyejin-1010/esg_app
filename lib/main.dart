import 'package:esg_app/screens/home.dart';
import 'package:esg_app/screens/login.dart';
import 'package:esg_app/screens/register_mission.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/route_manager.dart';
import 'package:esg_app/constant/color.dart';
import 'package:esg_app/screens/find_new_password.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'screens/find_password.dart';
import 'screens/join.dart';
import 'screens/start_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ShadcnApp(
      title: '가칭',
      theme: ThemeData(
        colorScheme: ColorSchemes.lightGreen(),
        radius: 0.5,
        typography: Typography.geist(sans: TextStyle(fontFamily: 'Pretendard')),
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
        fontFamily: 'Pretendard',
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
      ],
    );
  }
}
