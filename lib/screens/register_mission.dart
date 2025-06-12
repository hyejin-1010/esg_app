import 'dart:convert';
import 'dart:io';

import 'package:esg_app/constant/color.dart';
import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/controllers/feed_controller.dart';
import 'package:esg_app/controllers/mission_controller.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:esg_app/models/mission_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:esg_app/components/add_image_box.dart';

class RegisterMissionScreen extends StatefulWidget {
  const RegisterMissionScreen({super.key});

  @override
  State<RegisterMissionScreen> createState() => _RegisterMissionScreenState();
}

class _RegisterMissionScreenState extends State<RegisterMissionScreen> {
  FeedController feedController = Get.find<FeedController>();
  AuthController authController = Get.find<AuthController>();
  final TextEditingController _contentController = TextEditingController();

  int missionId = -1; // 미션 ID
  Mission? mission;
  final List<File> _images = []; // 이미지 리스트

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['id'] != null) {
      missionId = int.parse(args['id'].toString());
      _loadMission();
    }
  }

  void _loadMission() async {
    mission = await Get.find<MissionController>().getMission(missionId);
  }

  // 이미지 저장
  Future<String?> _saveImageToSupabase(File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final uuid = const Uuid().v4(); // 고유한 파일명 생성
      final extension = path.extension(imageFile.path); // 원본 파일의 확장자 유지
      final fileName = '$uuid$extension';
      final fileBytes = await imageFile.readAsBytes();

      await supabase.storage.from('esg').uploadBinary(fileName, fileBytes);

      // Get public URL
      final publicUrl = supabase.storage.from('esg').getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      debugPrint('[ERROR] save image to supabase: $error');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // 미션 저장 시 호출될 메서드
  Future<void> _saveMission() async {
    // TODO: 모두 입력했는 지 확인

    // 이미지들 모두 local directory에 저장
    final paths = <String>[];
    for (var image in _images) {
      try {
        final savedPath = await _saveImageToSupabase(image);
        if (savedPath != null) paths.add(savedPath);
      } catch (error) {
        debugPrint('[EROR] save image - local : $error');
      }
    }

    final newFeed = Feed(
      content: _contentController.text,
      userId: authController.userId,
      missionId: missionId,
      imagePathList: paths,
    );
    try {
      await feedController.addItem(newFeed);
    } catch (error) {
      debugPrint('[EROR] heidi save mission - feed : $error');
    }

    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text('등록 완료'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CO₂ 절감량 : ${mission?.co2.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}g',
                ),
                Text('포인트 : ${mission?.reward}P'),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Get.back();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '그린미션 등록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
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
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text('(최대 2개 까지만 등록 가능)', style: TextStyle(fontSize: 12.0)),
                  ],
                ),
                const SizedBox(height: 8.0),

                // 첨부 이미지
                Container(
                  color: const Color(0xFFF6FAFE),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      AddImageBox(
                        onImageSelected: (XFile file) {
                          _images.add(File(file.path));
                          setState(() {});
                        },
                      ),
                      ..._images.map((image) => _buildImageItem(image)),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: '탄소중립 실천을 위해 업로드한 이미지를 '),
                      TextSpan(
                        text: '3개월 후에 자동 삭제',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(text: '합니다.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 24.0,
            bottom: padding.bottom + 16.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(size.width - 48.0, 54.0),
              ),
              onPressed: _saveMission,
              child: Text(
                '등록하기',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일상 속 작은 실천을 기록하고 인증하며',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '함께 건강한 지구 만들어요!',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
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
        controller: _contentController,
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

  Widget _buildImageItem(File image) {
    return Stack(
      children: [
        SizedBox(
          width: 50.0,
          height: 50.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.file(image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4.0,
          right: 4.0,
          child: InkWell(
            onTap: () {
              _images.remove(image);
              setState(() {});
            },
            child: Icon(Icons.close, size: 16.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
