import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/controllers/mypage_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'upcycling_shop_screen.dart';
import 'post_detail_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/db/model_purchase_history.dart';
import 'package:esg_app/db/model_auth_dao.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:esg_app/controllers/feed_controller.dart';
import 'package:esg_app/components/feed_item.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class MyPageScreen extends StatefulWidget {
  final int initialTab;

  const MyPageScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _nickname;
  File? _profileImage;
  String? _profileImageUrl;
  List<Map<String, dynamic>> _purchaseHistory = [];
  final FeedController _feedController = Get.find<FeedController>();
  final AuthController _authController = Get.find<AuthController>();
  final AuthDao _authDao = AuthDao();
  int _points = 0;
  final MyPageController _myPageController = Get.put(MyPageController());
  bool _isUploadingProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _myPageController.refreshData();
      }
    });
    _myPageController.refreshData(); // 초기 데이터 로드
    _loadPurchaseHistory();
    _loadUserPosts();
    _loadNickname();
    _loadUserData();
    _loadProfileImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadUserData();
      _loadPurchaseHistory();
    });

    _myPageController.refreshData(); // 의존성이 변경될 때마다 데이터 리로드
  }

  Future<void> _loadNickname() async {
    final userId = _authController.userId;
    if (userId == null) return;

    final dbNickname = await _authDao.getNicknameByUserId(userId);
    final defaultNickname = _authController.user.email.split('@').first;

    setState(() {
      _nickname = dbNickname ?? defaultNickname;
    });
  }

  Future<void> _loadUserPosts() async {
    await _feedController.loadUserItems();
  }

  Future<void> _loadPurchaseHistory() async {
    final userId = _authController.userId;
    if (userId == null) return;

    final db = await DBHelper.database;
    final dao = PurchaseHistoryDao(db);
    final history = await dao.getByUserId(userId);
    setState(() {
      _purchaseHistory = history;
    });
  }

  Future<void> _loadUserData() async {
    if (_authController.user != null) {
      final points = await _authDao.getReward(_authController.user!.id);
      setState(() {
        _points = points;
      });
    }
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
                      onTap:
                          _isUploadingProfile ? null : _showImagePickerOptions,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _getProfileImage(),
                            child:
                                (_profileImage == null &&
                                        _profileImageUrl == null)
                                    ? Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          if (_isUploadingProfile)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                              _nickname ?? '',
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
                            _authController.user.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _authController.authLogout().then((value) {
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
                                    nickname: feed.userName ?? '',
                                    date: feed.createdAt,
                                    content: feed.content,
                                  ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: imageUrl,
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
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                          ),
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
      builder:
          (context) => AlertDialog(
            title: const Text('닉네임 변경'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '새 닉네임 입력'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final newNickname = controller.text.trim();
                  try {
                    await _authDao.updateNickname(
                      _authController.user.email,
                      newNickname,
                    );
                    await _loadNickname(); // 닉네임 다시 로드
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  Widget _buildESGStats() {
    return GetX<MyPageController>(
      builder:
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 포인트
                Column(
                  children: [
                    Image.asset(
                      'assets/images/mypage/btn_point.png',
                      width: 50,
                    ),
                    SizedBox(height: 4),
                    Text("포인트", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "${_myPageController.points} P",
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
                    Text(
                      "이산화탄소 절감",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${(_myPageController.co2.value / 1000).toStringAsFixed(2)}kg",
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
                      Image.asset(
                        'assets/images/mypage/btn_store.png',
                        width: 50,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "업사이클링",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
          ),
    );
  }

  Widget PurchaseHistoryTab() {
    return Obx(() {
      if (_myPageController.purchaseHistory.isEmpty) {
        return const Center(child: Text('구매 내역이 없습니다.'));
      }

      return ListView.builder(
        itemCount: _myPageController.purchaseHistory.length,
        itemBuilder: (context, index) {
          final history = _myPageController.purchaseHistory[index];
          final DateTime purchaseDate = DateTime.parse(
            history['purchaseDate'] as String,
          );

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
                    '${history['plantName'] ?? '식물'} | ${history['iconDescription']} | ${NumberFormat('#,###').format(history['price'])}P',
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
    });
  }

  Future<void> _loadProfileImage() async {
    final userId = _authController.userId;
    if (userId == null) return;

    try {
      final imageUrl = await _authDao.getProfileImageUrl(userId);
      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      debugPrint('[ERROR] 프로필 이미지 에러: $e');
    }
  }

  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  // 프로필 이미지를 Supabase에 저장
  Future<String?> _saveProfileImageToSupabase(File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final uuid = const Uuid().v4(); // 고유한 파일명 생성
      final extension = path.extension(imageFile.path); // 원본 파일의 확장자 유지
      final fileName = 'profile_$uuid$extension';
      final fileBytes = await imageFile.readAsBytes();

      await supabase.storage.from('esg').uploadBinary(fileName, fileBytes);

      // Get public URL
      final publicUrl = supabase.storage.from('esg').getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      debugPrint('[ERROR] save profile image to supabase: $error');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 이미지 업로드에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void _showImagePickerOptions() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.gallery);
                },
                child: const Text('갤러리에서 선택'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ),
    );
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _isUploadingProfile = true;
      });

      try {
        final imageFile = File(pickedFile.path);

        // Supabase에 이미지 업로드
        final imageUrl = await _saveProfileImageToSupabase(imageFile);

        if (imageUrl != null) {
          // Auth 테이블에 이미지 URL 저장
          final userId = _authController.userId;
          if (userId != null) {
            await _authDao.updateProfileImageUrl(userId, imageUrl);

            setState(() {
              _profileImage = imageFile;
              _profileImageUrl = imageUrl;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('프로필 이미지가 변경되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[ERROR] pick profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 이미지 변경에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploadingProfile = false;
        });
      }
    }
  }
}
