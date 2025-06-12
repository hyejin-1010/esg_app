import 'package:esg_app/controllers/auth.dart';
import 'package:flutter/material.dart';
import 'upcycling_shop_screen.dart';
import 'post_detail_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/db/model_purchase_history.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:esg_app/controllers/feed_controller.dart';
import 'package:esg_app/components/feed_item.dart';
import 'package:get/get.dart';

class MyPageScreen extends StatefulWidget {
  final int initialTab;

  const MyPageScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _nickname = '닉네임을 변경하세요!';
  File? _profileImage;
  List<Map<String, dynamic>> _purchaseHistory = [];
  final FeedController _feedController = Get.find<FeedController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadPurchaseHistory();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    await _feedController.loadUserItems();
  }

  Future<void> _loadPurchaseHistory() async {
    final db = await DBHelper.database;
    final dao = PurchaseHistoryDao(db);
    final history = await dao.getAllWithPlantName();
    setState(() {
      _purchaseHistory = history;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단 프로필 섹션
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                        child:
                            _profileImage == null
                                ? Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _nickname,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.edit, size: 20),
                            onPressed: _editNickname,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'heejin@example.com',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.find<AuthController>().authLogout().then((
                                value,
                              ) {
                                if (value) Get.offAllNamed('/start');
                              });
                            },
                            child: Text(
                              '로그아웃',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ESG 정보
          _buildESGStats(),

          // 탭바
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [Tab(text: '게시물'), Tab(text: '구매 내역')],
            ),
          ),

          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 게시물 탭
                Obx(() {
                  if (_feedController.userItems.isEmpty) {
                    return const Center(child: Text('작성한 게시물이 없습니다.'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(4.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _feedController.userItems.length,
                    itemBuilder: (context, index) {
                      final feed = _feedController.userItems[index];
                      if (feed.imagePathList.isEmpty ||
                          feed.imagePathList[0].isEmpty) {
                        return Container();
                      }
                      final imageUrl = feed.imagePathList[0];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PostDetailScreen(
                                    imageUrls: feed.imagePathList,
                                    nickname: feed.userName,
                                    date: feed.createdAt,
                                    content: feed.content,
                                  ),
                            ),
                          );
                        },
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                        ),
                      );
                    },
                  );
                }),
                // 구매 내역 탭
                PurchaseHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editNickname() {
    final controller = TextEditingController(text: _nickname);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('변경할 별명을 입력하세요'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "새 별명 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _nickname = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildESGStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 포인트
          Column(
            children: [
              Image.asset('assets/images/mypage/btn_point.png', width: 50),
              SizedBox(height: 4),
              Text("포인트", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "100P",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34C759),
                ),
              ),
            ],
          ),

          // 이산화탄소 절감
          Column(
            children: [
              Image.asset('assets/images/mypage/btn_co2.png', width: 50),
              SizedBox(height: 4),
              Text("이산화탄소 절감", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "3.25kg",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34C759),
                ),
              ),
            ],
          ),

          // 업사이클링 상점 (클릭 시 이동)
          GestureDetector(
            onTap: () {
              Get.toNamed('/upcyclingShop');
            },
            child: Column(
              children: [
                Image.asset('assets/images/mypage/btn_store.png', width: 50),
                SizedBox(height: 4),
                Text("업사이클링", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "상점",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF34C759),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget PurchaseHistoryTab() {
    if (_purchaseHistory.isEmpty) {
      return const Center(child: Text('구매 내역이 없습니다.'));
    }

    return ListView.builder(
      itemCount: _purchaseHistory.length,
      itemBuilder: (context, index) {
        final historyMap = _purchaseHistory[index];

        final int id = historyMap['id'] as int;
        final String plantName = historyMap['plantName'] as String;
        final String iconDescription = historyMap['iconDescription'] as String;
        final int price = historyMap['price'] as int;
        final String purchaseDateString = historyMap['purchaseDate'] as String;
        final String address = historyMap['address'] as String;
        final String detailAddress = historyMap['detailAddress'] as String;

        final DateTime purchaseDate = DateTime.parse(purchaseDateString);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy.MM.dd HH:mm').format(purchaseDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '구매완료',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${plantName} | ${iconDescription} | ${NumberFormat('#,###').format(price)}P',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
}
