import 'dart:math';

import 'package:flutter/material.dart' as material;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../controllers/auth.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String userId = '';
  String email = '';
  String password = '';
  String? userIdErrorText;
  bool isDuplicate = false;
  bool isLoading = false;

  final _formKey = material.GlobalKey<material.FormState>();

  final getxController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
    });
  }

  void onChangedUserId(String? text) {
    setState(() {
      userId = text ?? '';
    });
  }

  void onChangedEmail(String? text) {
    setState(() {
      email = text ?? '';
    });
  }

  void onChangedPassword(String? text) {
    setState(() {
      password = text ?? '';
    });
  }

  String? userIdValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '아이디를 입력해 주세요.';
    }
    if (value.length < 4) {
      return '아이디는 4자 이상 입력해 주세요.';
    }
    // if (isDuplicate) {
    //   return '이미 사용중인 아이디입니다.';
    // }
    if (value.length > 20) {
      return '아이디는 20자 이하로 입력해 주세요.';
    }
    if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return null;
    } else {
      return '아이디는 영문자와 숫자만 입력 가능합니다.';
    }
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상 입력해 주세요.';
    }
    if (value.length > 20) {
      return '비밀번호는 20자 이하로 입력해 주세요.';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return '유효한 이메일 주소를 입력해 주세요.';
    }
    return null;
  }

  // 실제 서버가 없으니 랜덤으로 중복 체크
  void checkDuplicateId() {
    int random = Random().nextInt(3);
    String? errorText = userIdValidator(userId);

    if (random != 0 && errorText == null) {
      setState(() {
        userIdErrorText = '이미 사용중인 아이디입니다.';
        isDuplicate = false;
      });
    } else if (random == 0 && errorText == null) {
      // 성공
      setState(() {
        userIdErrorText = errorText;
        isDuplicate = true;
      });
    } else {
      // 실패
      setState(() {
        userIdErrorText = errorText;
        isDuplicate = false;
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
        // 회원가입
        await getxController.authJoin(
          userId: userId,
          email: email,
          password: password,
        );

        // 회원가입 성공 후 홈 화면으로 이동
        Navigator.of(context).pushNamed('/home');
      }

      setState(() {
        isLoading = false;
      });
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
                        material.Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            material.Flexible(
                              child: CustomTextFormField(
                                label: '아이디',
                                icon: Icons.person,
                                enabled: !isDuplicate,
                                errorText: userIdErrorText,
                                validator: userIdValidator,
                                onChanged: onChangedUserId,
                              ),
                            ),
                            Gap(8),
                            material.SizedBox(
                              height: 56,
                              child: Button(
                                style: const ButtonStyle.primary()
                                    .withBackgroundColor(
                                      color: Colors.green,
                                      disabledColor: Colors.green.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                onPressed:
                                    !isDuplicate ? checkDuplicateId : null,
                                child:
                                    const Text(
                                      '중복체크',
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                      ),
                                    ).black,
                              ),
                            ),
                          ],
                        ),
                        Gap(20),
                        CustomTextFormField(
                          label: '비밀번호',
                          icon: Icons.lock,
                          validator: passwordValidator,
                          onChanged: onChangedPassword,
                          obscureText: true,
                        ),
                        Gap(20),
                        CustomTextFormField(
                          label: '이메일',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: emailValidator,
                          onChanged: onChangedEmail,
                          onFieldSubmitted: onSubmit,
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
                            onPressed: onSubmit,
                            child:
                                isLoading
                                    ? CircularProgressIndicator(animated: true)
                                    : const Text(
                                      '가입하기',
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

class CustomTextFormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final bool? enabled;
  final bool obscureText;
  final String? errorText;
  final void Function(String)? onChanged;
  final void Function()? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return material.TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: (_) {
        if (onFieldSubmitted != null) {
          onFieldSubmitted!();
        }
      },
      autocorrect: false,
      decoration: material.InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icon, color: Colors.green),
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        disabledBorder: material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0, color: Colors.green),
        ),
        enabledBorder: const material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0),
        ),
        errorBorder: const material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0),
        ),
        focusedErrorBorder: const material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0, color: Colors.red),
        ),
      ),
    );
  }
}
