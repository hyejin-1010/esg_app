import 'dart:math';

import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../utils/validators.dart';
import '../widgets/custom_text_form_field.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  String email = '';
  String authCode = '';
  String? errorText;
  bool isLoading = false;
  bool isSendAuthCode = false;

  final _formKey = material.GlobalKey<material.FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
    });
  }

  void onChangedEmail(String text) {
    setState(() {
      email = text;
    });
  }

  void onChangedAuthCode(String text) {
    setState(() {
      authCode = text;
    });
  }

  void onSubmitAuthCode() async {
    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      String? newErrorText = UtilValidators.email(email);

      print('hello $newErrorText');

      if (newErrorText == null) {
        // 인증코드 확인 후 비밀번호 변경 화면으로 이동
        showToast(
          context: context,
          builder: buildToast,
          location: ToastLocation.topCenter,
        );
        errorText = null;
      } else {
        throw Exception(newErrorText);
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

  void onSubmit() async {
    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      if (_formKey.currentState!.validate()) {
        // 회원가입 성공 후 홈 화면으로 이동
        Navigator.of(context).pushNamed('/find/new/password');
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
                          label: '이메일',
                          keyboardType: TextInputType.emailAddress,
                          validator: UtilValidators.email,
                          onChanged: onChangedEmail,
                          errorText: errorText,
                        ),
                        Gap(8),
                        material.Row(
                          mainAxisAlignment: material.MainAxisAlignment.end,
                          children: [
                            Button(
                              style: const ButtonStyle.primary()
                                  .withBackgroundColor(
                                    color: Colors.green,
                                    disabledColor: Colors.green.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                              onPressed:
                                  email.isNotEmpty ? onSubmitAuthCode : null,
                              child:
                                  isLoading
                                      ? CircularProgressIndicator(
                                        animated: true,
                                      )
                                      : const Text(
                                        '인증코드 발송',
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                        ),
                                      ).black,
                            ),
                          ],
                        ),
                        Gap(20),
                        CustomTextFormField(
                          label: '인증코드 6자리',
                          keyboardType: TextInputType.number,
                          validator: UtilValidators.authCode,
                          onChanged: onChangedAuthCode,
                          // onFieldSubmitted: onSubmit,
                          errorText: errorText,
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
                                email.isNotEmpty && authCode.isNotEmpty
                                    ? onSubmit
                                    : null,
                            child:
                                isLoading
                                    ? CircularProgressIndicator(animated: true)
                                    : const Text(
                                      '다음',
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
