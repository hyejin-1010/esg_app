import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import '../db/db_helper.dart';
import '../db/model_purchase_history.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class UpcyclingShopOrderScreen extends StatefulWidget {
  final String selectedPlantName;
  final int price;
  final int plantItemId;
  final String imageAsset;

  const UpcyclingShopOrderScreen({
    Key? key,
    required this.selectedPlantName,
    required this.price,
    required this.plantItemId,
    required this.imageAsset,
  }) : super(key: key);

  @override
  State<UpcyclingShopOrderScreen> createState() => _UpcyclingShopOrderScreenState();
}

class _UpcyclingShopOrderScreenState extends State<UpcyclingShopOrderScreen> {
  String? postCode;
  String? address;
  final TextEditingController _detailAddressController = TextEditingController();
  String? selectedIcon; // 선택된 아이콘을 저장할 변수 (asset path)

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
    if (postCode == null || address == null || _detailAddressController.text.isEmpty || selectedIcon == null) {
      // TODO: 사용자에게 입력 누락 알림
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
      plantItemId: widget.plantItemId,
      // plantName과 plantImage는 PurchaseHistory 모델에 포함되지 않으므로 제거합니다.
      // plantName: widget.selectedPlantName,
      // plantImage: widget.imageAsset,
      price: widget.price,
      purchaseDate: formattedDate,
      postCode: postCode!,
      address: address!,
      detailAddress: _detailAddressController.text,
      iconDescription: iconDescription, // 아이콘 설명 저장
    );

    await dao.insert(history);
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
                Text(
                  '508P',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                  widget.imageAsset,
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
                              isSelected: selectedIcon == 'assets/images/mypage/ic_beer.png',
                              onTap: () => _selectIcon('assets/images/mypage/ic_beer.png'),
                            ),
                            SizedBox(width: 12),
                            _iconBox(
                              'assets/images/mypage/ic_cup.png',
                              isSelected: selectedIcon == 'assets/images/mypage/ic_cup.png',
                              onTap: () => _selectIcon('assets/images/mypage/ic_cup.png'),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _iconBox(
                              'assets/images/mypage/ic_denim.png',
                              isSelected: selectedIcon == 'assets/images/mypage/ic_denim.png',
                              onTap: () => _selectIcon('assets/images/mypage/ic_denim.png'),
                            ),
                            SizedBox(width: 12),
                            _iconBox(
                              'assets/images/mypage/ic_shopbag.png',
                              isSelected: selectedIcon == 'assets/images/mypage/ic_shopbag.png',
                              onTap: () => _selectIcon('assets/images/mypage/ic_shopbag.png'),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                            color: postCode != null ? Colors.black : Colors.grey,
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
            onPressed: (postCode != null && _detailAddressController.text.isNotEmpty && selectedIcon != null)
                ? () async {
                    await _savePurchaseHistory();
                    _showPurchaseCompleteDialog(context);
                  }
                : null,
            child: Text(
              '${widget.price}P로 구매하기',
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
        builder: (_) => KpostalView(
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

  Widget _iconBox(String asset, {bool isSelected = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE6F7EC) : Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: Color(0xFF22C55E), width: 2) : null,
          ),
          child: Center(
            child: Image.asset(asset, height: 40),
          ),
        ),
      ),
    );
  }

  void _showPurchaseCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            '구매완료',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        ),
        content: Text(
          '제작 기간을 포함해 15일 이내에\n배송됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                // 다이얼로그 닫기
                Navigator.pop(context);
                // 모든 화면을 닫고 HomeScreen의 기본 탭으로 이동
                Get.offAllNamed('/home');
              },
              child: Text('OK', style: TextStyle(fontSize: 20, color: Colors.blue)),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
} 