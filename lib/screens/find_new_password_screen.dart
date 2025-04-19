import 'package:shadcn_flutter/shadcn_flutter.dart';

class FindNewPasswordScreen extends StatefulWidget {
  const FindNewPasswordScreen({super.key});

  @override
  State<FindNewPasswordScreen> createState() => _FindNewPasswordScreenState();
}

class _FindNewPasswordScreenState extends State<FindNewPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(child: SafeArea(child: Center(child: Text('새로운 비밀번호 화면'))));
  }
}
