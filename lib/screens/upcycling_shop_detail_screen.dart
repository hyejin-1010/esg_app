import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db/model_plant_item.dart';
import '../db/model_plant_item_dao.dart';
import '../db/db_helper.dart';
import 'upcycling_shop_order_screen.dart';

class UpcyclingShopDetailScreen extends StatefulWidget {
  const UpcyclingShopDetailScreen({Key? key}) : super(key: key);

  @override
  State<UpcyclingShopDetailScreen> createState() =>
      _UpcyclingShopDetailScreenState();
}

class _UpcyclingShopDetailScreenState extends State<UpcyclingShopDetailScreen> {
  int? _selectedIndex;
  List<PlantItem> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final db = await DBHelper.database;
    final dao = PlantItemDao(db);
    final items = await dao.getAll();
    setState(() {
      _plants = items;
      _isLoading = false;
    });
  }

  void _onNextPressed() {
    if (_selectedIndex != null) {
      final selectedPlant = _plants[_selectedIndex!];
      print('선택한 식물 정보:');
      print('ID: ${selectedPlant.id}');
      print('이름: ${selectedPlant.name}');
      print('설명: ${selectedPlant.description}');
      print('가격: ${selectedPlant.price}P');
      print('이미지 경로: ${selectedPlant.imageAsset}');

      Get.toNamed(
        '/upcyclingShopOrder',
        arguments: {
          'selectedPlantName': selectedPlant.name,
          'price': selectedPlant.price,
          'plantItemId': selectedPlant.id,
          'imageAsset': selectedPlant.imageAsset,
        },
      );
    }
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
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(text: '당신의 일상에 '),
                              TextSpan(
                                text: '초록',
                                style: TextStyle(color: Color(0xFF1DB954)),
                              ),
                              TextSpan(text: '을 더해줄\n'),
                              TextSpan(
                                text: '식물',
                                style: TextStyle(color: Color(0xFF1DB954)),
                              ),
                              TextSpan(text: '을 선택해보세요.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_plants.length, (index) {
                        final plant = _plants[index];
                        return _buildPlantOption(
                          plant.name,
                          plant.description,
                          selected: _selectedIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        );
                      }),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 24, right: 24),
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
            onPressed: _onNextPressed,
            child: Text(
              '다음',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantOption(
    String title,
    String subtitle, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: selected ? Color(0xFFE6F7EC) : Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(18),
            border:
                selected
                    ? Border.all(color: Color(0xFF22C55E), width: 3)
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: selected ? Color(0xFF22C55E) : Color(0xFF4B4B4B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B4B4B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
