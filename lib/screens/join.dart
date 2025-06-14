import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../controllers/auth.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_form_field.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String email = '';
  String password = '';
  String? emailErrorText;
  String? nicknameErrorText;
  bool isNotDuplicate = false;
  bool isLoading = false;

  final _formKey = material.GlobalKey<material.FormState>();

  final getxController = Get.put(AuthController());

  void onChangedEmail(String? text) {
    isNotDuplicate = false;
    setState(() {
      email = text ?? '';
    });
  }

  void onChangedPassword(String? text) {
    setState(() {
      password = text ?? '';
    });
  }

  // 실제 서버가 없으니 랜덤으로 중복 체크
  Future<void> checkDuplicateNickname() async {
    String? errorText = UtilValidators.email(email);
    final isDuplicateEmail = await getxController.authCheckDuplicateEmail(
      email: email,
    );

    if (isDuplicateEmail && errorText == null) {
      setState(() {
        emailErrorText = '이미 사용중인 이메일입니다.';
        isNotDuplicate = false;
      });
    } else if (errorText == null) {
      // 성공
      setState(() {
        emailErrorText = null;
        isNotDuplicate = true;
      });
    } else {
      // 실패
      setState(() {
        nicknameErrorText = errorText;
        isNotDuplicate = false;
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
        final nickname = email.split('@')[0];
        // 회원가입
        await getxController.authJoin(
          nickname: nickname,
          email: email,
          password: password,
        );

        // 회원가입 성공 후 홈 화면으로 이동
        Get.offAllNamed('/home');
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      nicknameErrorText = error.toString().replaceFirst('Exception: ', '');
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
                                label: '이메일',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: UtilValidators.email,
                                onChanged: onChangedEmail,
                                onFieldSubmitted: onSubmit,
                                errorText: emailErrorText,
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
                                    !isNotDuplicate
                                        ? checkDuplicateNickname
                                        : null,
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
                          validator: UtilValidators.password,
                          onChanged: onChangedPassword,
                          obscureText: true,
                        ),
                        Gap(20),

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
                            onPressed: isNotDuplicate ? onSubmit : null,
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
