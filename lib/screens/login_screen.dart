import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';

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
                  child: Column(
                    children: [
                      Gap(80),
                      Image.asset('assets/images/green_earth.png', width: 180),
                      Gap(80),
                      material.TextField(
                        decoration: material.InputDecoration(
                          labelText: '이메일',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: material.OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: material.OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            borderSide: BorderSide(width: 0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: onChangedEmail,
                      ),
                      Gap(20),
                      material.TextField(
                        decoration: material.InputDecoration(
                          labelText: '비밀번호',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: material.OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: material.OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            borderSide: BorderSide(width: 0),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: onChangedPassword,
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
                                  ? () {}
                                  : null,
                          child:
                              const Text(
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
