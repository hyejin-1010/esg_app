import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterMissionScreen extends StatefulWidget {
  const RegisterMissionScreen({super.key});

  @override
  State<RegisterMissionScreen> createState() => _RegisterMissionScreenState();
}

class _RegisterMissionScreenState extends State<RegisterMissionScreen> {
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['id'] != null) {
      print('Mission ID: ${args['id']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '그린미션 등록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            _buildInputContent(),
            Row(
              children: [
                Text(
                  '사진 등록',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 4.0),
                Text('최대 2개 까지만 등록 가능', style: TextStyle(fontSize: 13.0)),
              ],
            ),
            const SizedBox(height: 8.0),
            Container(
              color: const Color(0xFFF6FAFE),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('일상 속 작은 실천을 기록하고 인증하며', style: TextStyle(fontSize: 18.0)),
        Text(
          '함께 건강한 지구 만들어요!',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInputContent() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: TextField(
        minLines: 6,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: 'Ex) 동아리 사람들과 플로깅~ 가벼운 실천으로 환굥을 보호할 수 있어서 너무 뿌듯했다!',
          border: InputBorder.none,
          hintStyle: TextStyle(color: const Color(0xFF999999)),
        ),
      ),
    );
  }
}
