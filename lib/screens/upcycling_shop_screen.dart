import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpcyclingShopScreen extends StatelessWidget {
  const UpcyclingShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bottomBarHeight = MediaQuery.of(context).size.height * 0.12;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3ED),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/mypage/shop_banner.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            SizedBox(height: 100), // 버튼과 겹치지 않게
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        height: bottomBarHeight,
        child: GestureDetector(
          onTap: () {
            Get.toNamed('/upcyclingShopDetail');
          },
          child: Image.asset(
            'assets/images/mypage/btn_shop.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
