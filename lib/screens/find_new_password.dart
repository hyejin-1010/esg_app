import 'dart:math';

import 'package:esg_app/controllers/auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../utils/validators.dart';
import '../widgets/custom_text_form_field.dart';

class FindNewPasswordScreen extends StatefulWidget {
  const FindNewPasswordScreen({super.key});

  @override
  State<FindNewPasswordScreen> createState() => _FindNewPasswordScreenState();
}

class _FindNewPasswordScreenState extends State<FindNewPasswordScreen> {
  String password = '';
  String checkPassword = '';
  String? errorText;
  bool isLoading = false;

  final _formKey = material.GlobalKey<material.FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
    });
  }

  void onChangedPassword(String text) {
    setState(() {
      password = text;
    });
  }

  void onChangedCheckPassword(String text) {
    setState(() {
      checkPassword = text;
    });
  }

  void onSubmit() async {
    if (isLoading) return;

    try {
      if (password != checkPassword) {
        throw Exception('비밀번호가 일치하지 않습니다.');
      }

      setState(() {
        isLoading = true;
      });

      if (_formKey.currentState!.validate()) {
        final success = await Get.find<AuthController>().authUpdatePassword(
          email: Get.arguments['email'],
          password: password,
        );
        if (!success) throw Exception('비밀번호 변경에 실패했습니다.');
        // 회원가입 성공 후 홈 화면으로 이동
        Get.offNamedUntil('/login', (route) => false);
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      errorText = error.toString().replaceFirst('Exception: ', '');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: material.Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Gap(80),
                        Image.asset(
                          'assets/images/green_earth.png',
                          width: 180,
                        ),
                        Gap(80),
                        CustomTextFormField(
                          label: '새로운 비밀번호 입력',
                          keyboardType: TextInputType.text,
                          validator: UtilValidators.password,
                          onChanged: onChangedPassword,
                          errorText: errorText,
                          obscureText: true,
                        ),
                        Gap(8),
                        Gap(20),
                        CustomTextFormField(
                          label: '새로운 비밀번호 재 입력',
                          keyboardType: TextInputType.text,
                          validator: UtilValidators.password,
                          onChanged: onChangedCheckPassword,
                          onFieldSubmitted: onSubmit,
                          errorText: errorText,
                          obscureText: true,
                        ),
                        Gap(20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 50,
                          child: Button(
                            style: const ButtonStyle.primary()
                                .withBackgroundColor(
                                  color: Colors.green,
                                  disabledColor: Colors.green.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                            onPressed:
                                password.isNotEmpty && checkPassword.isNotEmpty
                                    ? onSubmit
                                    : null,
                            child:
                                isLoading
                                    ? CircularProgressIndicator(animated: true)
                                    : const Text(
                                      '완료',
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                      ),
                                    ).black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildToast(BuildContext context, ToastOverlay overlay) {
  List<int> randomNumbers = [
    Random().nextInt(9),
    Random().nextInt(9),
    Random().nextInt(9),
    Random().nextInt(9),
    Random().nextInt(9),
    Random().nextInt(9),
  ];
  return SurfaceCard(
    child: Basic(
      title: Text(randomNumbers.join()),
      trailing: PrimaryButton(
        size: ButtonSize.small,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: randomNumbers.join()));
          overlay.close();
        },
        child: const Text('복사'),
      ),
      trailingAlignment: Alignment.center,
    ),
  );
}
