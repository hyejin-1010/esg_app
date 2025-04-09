import 'package:esg_app/screens/home.dart';
import 'package:esg_app/screens/login.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/route_manager.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: material.ThemeData(
        colorScheme: material.ColorScheme.light(
          primary: Color(0xFF34C759), // 메인 컬러 지정
        ),
      ),
      routes: {'/': (context) => Home(), '/first': (context) => LoginScreen()},
    );
  }
}
