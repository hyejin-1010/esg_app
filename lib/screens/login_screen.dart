import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../controllers/auth.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  String? errorText;
  bool isLoading = false;

  final _formKey = material.GlobalKey<material.FormState>();

  final getxController = Get.put(AuthController());

  void onChangedEmail(String text) {
    setState(() {
      email = text;
    });
  }

  void onChangedPassword(String text) {
    setState(() {
      password = text;
    });
  }

  void onSubmit() async {
    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      if (_formKey.currentState!.validate()) {
        // 회원가입
        await getxController.authLogin(email: email, password: password);

        // 회원가입 성공 후 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
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
                        Gap(20),
                        CustomTextFormField(
                          label: '비밀번호',
                          keyboardType: TextInputType.text,
                          validator: UtilValidators.password,
                          onChanged: onChangedPassword,
                          onFieldSubmitted: onSubmit,
                          errorText: errorText,
                          obscureText: true,
                        ),
                        Gap(40),
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
                                email.isNotEmpty && password.isNotEmpty
                                    ? onSubmit
                                    : null,
                            child:
                                isLoading
                                    ? CircularProgressIndicator(animated: true)
                                    : const Text(
                                      '로그인',
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                      ),
                                    ).black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/find/password');
                          },
                          child:
                              Text(
                                '비밀번호를 잊으셨나요?',
                                style: TextStyle(color: Colors.green),
                              ).xSmall.semiBold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/join');
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '계정이 없으신가요? ',
                          style: TextStyle(
                            color: Colors.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
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
