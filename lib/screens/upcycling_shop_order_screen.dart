import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import '../db/db_helper.dart';
import '../db/model_purchase_history.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/db/model_auth_dao.dart';
import 'package:esg_app/screens/mypage.dart';
import 'package:esg_app/controllers/mypage_controller.dart';

class UpcyclingShopOrderScreen extends StatefulWidget {
  const UpcyclingShopOrderScreen({Key? key}) : super(key: key);

  @override
  State<UpcyclingShopOrderScreen> createState() =>
      _UpcyclingShopOrderScreenState();
}

class _UpcyclingShopOrderScreenState extends State<UpcyclingShopOrderScreen> {
  String? postCode;
  String? address;
  final TextEditingController _detailAddressController =
      TextEditingController();
  String? selectedIcon; // 선택된 아이콘을 저장할 변수 (asset path)

  String? selectedPlantName;
  int? price;
  int? plantItemId;
  String? imageAsset;

  final AuthController _authController = Get.find<AuthController>();
  final AuthDao _authDao = AuthDao();
  final MyPageController _myPageController = Get.put(MyPageController());
  int _points = 0; // 포인트 변수 추가

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    selectedIcon = arguments['imageAsset'];
    selectedPlantName = arguments['selectedPlantName'];
    price = arguments['price'];
    plantItemId = arguments['plantItemId'];
    imageAsset = arguments['imageAsset'];
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_authController.user != null) {
      final points = await _authDao.getReward(_authController.user!.id);
      setState(() {
        _points = points;
      });
    }
  }

  // 아이콘 파일 경로를 설명 문자열로 매핑하는 함수
  String _mapIconPathToDescription(String iconPath) {
    switch (iconPath) {
      case 'assets/images/mypage/ic_beer.png':
        return '맥주병';
      case 'assets/images/mypage/ic_cup.png':
        return '컵';
      case 'assets/images/mypage/ic_denim.png':
        return '데님';
      case 'assets/images/mypage/ic_shopbag.png':
        return '쇼핑백';
      default:
        return '알 수 없음'; // 또는 다른 기본값
    }
  }

  Future<void> _savePurchaseHistory() async {
    // 주소, 상세주소, 아이콘이 모두 입력되어야 저장
    if (postCode == null ||
        address == null ||
        _detailAddressController.text.isEmpty ||
        selectedIcon == null) {
      // TODO: 사용자에게 입력 누락 알림
      return;
    }

    // 포인트 차감 시도
    if (_authController.user == null) return;
    final success = await _authDao.deductReward(
      _authController.user!.id,
      price!,
    );

    if (!success) {
      // 포인트 부족 시 팝업 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text(
                '포인트 부족',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            content: Text(
              '보유 포인트가 부족합니다.\n필요 포인트: ${price}P\n보유 포인트: ${_points}P',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      );
      return;
    }

    final db = await DBHelper.database;
    final dao = PurchaseHistoryDao(db);

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // 선택된 아이콘의 설명 문자열 가져오기
    final iconDescription = _mapIconPathToDescription(selectedIcon!);

    final history = PurchaseHistory(
      id: 0, // DB에서 자동 생성
      plantItemId: plantItemId!,
      price: price!,
      purchaseDate: formattedDate,
      postCode: postCode!,
      address: address!,
      detailAddress: _detailAddressController.text,
      iconDescription: iconDescription, // 아이콘 설명 저장
      userId: _authController.user!.id, // 사용자 ID 추가
    );

    await dao.insert(history);

    // 구매 완료 후 포인트 업데이트
    await _loadUserData();
    await _myPageController.refreshData(); // 마이페이지 데이터 새로고침

    // 구매 완료 팝업 표시
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              '구매 완료',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: const Text(
            '식물 구매가 완료되었습니다.\n제작 기간을 포함하여 15일 이내에 배송될 예정입니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Get.until((route) => route.isFirst);
                  await _myPageController.refreshData(); // 마이페이지로 이동 전 데이터 새로고침
                  //Get.toNamed('/mypage');
                },
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF1B7B4C),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                const Text('포인트'),
                Text(
                  '$_points P', // 하드코딩된 값 대신 _points 사용
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 식물 이미지
              Center(
                child: Image.asset(
                  imageAsset!,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              // 아이콘 그리드
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 36),
                    onPressed: () {
                      // TODO: 이전 아이콘 세트로 이동
                    },
                  ),
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _iconBox(
                              'assets/images/mypage/ic_beer.png',
                              isSelected:
                                  selectedIcon ==
                                  'assets/images/mypage/ic_beer.png',
                              onTap:
                                  () => _selectIcon(
                                    'assets/images/mypage/ic_beer.png',
                                  ),
                            ),
                            SizedBox(width: 12),
                            _iconBox(
                              'assets/images/mypage/ic_cup.png',
                              isSelected:
                                  selectedIcon ==
                                  'assets/images/mypage/ic_cup.png',
                              onTap:
                                  () => _selectIcon(
                                    'assets/images/mypage/ic_cup.png',
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _iconBox(
                              'assets/images/mypage/ic_denim.png',
                              isSelected:
                                  selectedIcon ==
                                  'assets/images/mypage/ic_denim.png',
                              onTap:
                                  () => _selectIcon(
                                    'assets/images/mypage/ic_denim.png',
                                  ),
                            ),
                            SizedBox(width: 12),
                            _iconBox(
                              'assets/images/mypage/ic_shopbag.png',
                              isSelected:
                                  selectedIcon ==
                                  'assets/images/mypage/ic_shopbag.png',
                              onTap:
                                  () => _selectIcon(
                                    'assets/images/mypage/ic_shopbag.png',
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 36),
                    onPressed: () {
                      // TODO: 다음 아이콘 세트로 이동
                    },
                  ),
                ],
              ),
              SizedBox(height: 32),

              // 배송지 입력
              Text(
                '배송지 입력',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // 우편번호 입력
              GestureDetector(
                onTap: () => _showAddressSearch(),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          postCode != null ? '($postCode) $address' : '우편번호 찾기',
                          style: TextStyle(
                            color:
                                postCode != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 상세주소 입력
              TextField(
                controller: _detailAddressController,
                decoration: InputDecoration(
                  hintText: '상세 주소를 입력하세요',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (text) {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF22C55E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed:
                (postCode != null &&
                        _detailAddressController.text.isNotEmpty &&
                        selectedIcon != null)
                    ? () async {
                      await _savePurchaseHistory();
                    }
                    : null,
            child: Text(
              '${price}P로 구매하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => KpostalView(
              useLocalServer: true,
              localPort: 8080,
              callback: (Kpostal result) {
                if (mounted) {
                  setState(() {
                    postCode = result.postCode;
                    address = result.address;
                  });
                }
              },
            ),
      ),
    );
  }

  void _selectIcon(String iconPath) {
    setState(() {
      selectedIcon = iconPath;
    });
  }

  Widget _iconBox(
    String asset, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE6F7EC) : Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(18),
            border:
                isSelected
                    ? Border.all(color: Color(0xFF22C55E), width: 2)
                    : null,
          ),
          child: Center(child: Image.asset(asset, height: 40)),
        ),
      ),
    );
  }
}
