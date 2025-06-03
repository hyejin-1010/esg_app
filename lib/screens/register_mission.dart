import 'dart:io';

import 'package:esg_app/constant/color.dart';
import 'package:esg_app/controllers/feed_controller.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'package:esg_app/components/add_image_box.dart';

class RegisterMissionScreen extends StatefulWidget {
  const RegisterMissionScreen({super.key});

  @override
  State<RegisterMissionScreen> createState() => _RegisterMissionScreenState();
}

class _RegisterMissionScreenState extends State<RegisterMissionScreen> {
  FeedController feedController = Get.find();
  final TextEditingController _contentController = TextEditingController();

  int missionId = -1; // 미션 ID
  final List<File> _images = []; // 이미지 리스트

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['id'] != null) {
      missionId = int.parse(args['id'].toString());
    }
  }

  // 이미지 저장
  Future<String> _saveImageToLocal(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final uuid = const Uuid().v4(); // 고유한 파일명 생성
    final extension = path.extension(imageFile.path); // 원본 파일의 확장자 유지
    final fileName = '$uuid$extension';
    final savedPath = path.join(directory.path, 'mission_images', fileName);

    // 디렉토리가 없으면 생성
    final imageDir = Directory(path.dirname(savedPath));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // 이미지 파일 복사
    await imageFile.copy(savedPath);
    return savedPath;
  }

  // 미션 저장 시 호출될 메서드
  Future<void> _saveMission() async {
    // TODO: 모두 입력했는 지 확인

    // 이미지들 모두 local directory에 저장
    final paths = <String>[];
    for (var image in _images) {
      try {
        final savedPath = await _saveImageToLocal(image);
        paths.add(savedPath);
      } catch (error) {
        debugPrint('[EROR] save image - local : $error');
      }
    }

    final userId = 1; // TODO: 나의 ID 가져오기
    final userName = 'test'; // TODO: 나의 이름 가져오기

    final newFeed = Feed(
      content: _contentController.text,
      userId: userId,
      userName: userName,
      missionId: missionId,
      imagePathList: paths,
    );
    try {
      await feedController.addItem(newFeed);
    } catch (error) {
      debugPrint('[EROR] heidi save mission - feed : $error');
    }

    Get.back();
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
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text('최대 2개 까지만 등록 가능', style: TextStyle(fontSize: 13.0)),
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
                        style: TextStyle(fontWeight: FontWeight.bold),
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
