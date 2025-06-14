import 'package:esg_app/controllers/auth.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:gif/gif.dart';
import 'package:get/get.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    authController.init().then((value) {
      print('heidi test user id ${authController.userId}');
      if (authController.userId != null) Get.offAndToNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: topPadding + 40),
            child: Image.asset(
              'assets/images/splash-logo.png',
              fit: BoxFit.contain,
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
            bottom: bottomPadding + 180,
            child: Gif(
              fps: 30,
              autostart: Autostart.once,
              placeholder:
                  (context) => const Center(child: CircularProgressIndicator()),
              image: const AssetImage('assets/images/green_earth.gif'),
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width + 10,
            ),
          ),

          Positioned(
            bottom: bottomPadding + 20,
            left: 40,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Button(
                    style: const ButtonStyle.primary().withBackgroundColor(
                      color: Colors.green,
                    ),
                    onPressed: () {
                      Get.offAndToNamed('/login');
                    },
                    child:
                        const Text(
                          '시작하기',
                          style: TextStyle(decoration: TextDecoration.none),
                        ).large.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
