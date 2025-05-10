import 'package:get/route_manager.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      child: Stack(
        children: [
          Image.asset('assets/images/splash.png', fit: BoxFit.cover),
          Positioned(
            bottom: bottomPadding + 20,
            left: 40,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 80,
              child: Button(
                style: const ButtonStyle.primary().withBackgroundColor(
                  color: Colors.green,
                ),
                onPressed: () {
                  Get.toNamed('/login');
                },
                child:
                    const Text(
                      '시작하기',
                      style: TextStyle(decoration: TextDecoration.none),
                    ).large.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
