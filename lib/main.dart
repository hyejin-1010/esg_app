// import 'package:flutter/material.dart' as material;
import 'package:esg_app/screens/find_new_password_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'screens/find_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/join_screen.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const GetMaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: '가칭',
      theme: ThemeData(colorScheme: ColorSchemes.lightGreen(), radius: 0.5),
      home: FindPasswordScreen(),
      routes: {
        '/start': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),
        '/join': (context) => const JoinScreen(),
        '/find/password': (context) => const FindPasswordScreen(),
        '/find/new/password': (context) => const FindNewPasswordScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final int _counter = 0;

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return material.MaterialApp(home: StartScreen());
//   }
// }
