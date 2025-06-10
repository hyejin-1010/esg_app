import 'package:flutter/services.dart';

import 'package:esg_app/controllers/map_controller.dart';
import 'package:esg_app/models/map_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'dart:async';
import 'dart:developer';

import '../components/mission/search_box.dart';
import '../components/map/poi_list_item.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = Get.find<MapController>();
  late final NaverMapController _naverMapController;
  late final SheetController _sheetController;
  static const _defaultZoom = 14.0;

  int? selectedCategoryId;
  Timer? _debounceTimer;
  bool showSearchButton = false;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    _sheetController = SheetController();

    _loadStoreData();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStoreData() async {
    await _mapController.loadStoreData();
  }

  // 아이콘 경로 반환
  String _getIconPath(String category) {
    switch (category) {
      case '리필샵':
        return 'assets/icon/map/refill_shop.png';
      case '친환경생필품점':
        return 'assets/icon/map/eco.png';
      case '카페':
        return 'assets/icon/map/cafe.png';
      case '식당':
        return 'assets/icon/map/restaurant.png';
      case '일반쓰레기':
        return 'assets/icon/map/general_waste.png';
      case '재활용쓰레기':
      case '일반쓰레기+재활용쓰':
        return 'assets/icon/map/recyclable_waste.png';
      default:
        return 'assets/icon/map/others.png';
    }
  }

  // 아이콘 이미지 반환
  Future<NOverlayImage> _getIconImage(String iconPath) async {
    final ByteData data = await rootBundle.load(iconPath);
    final bytes = data.buffer.asUint8List();
    return await NOverlayImage.fromByteArray(bytes);
  }

  // 내 위치로 카메라 이동
  void _moveCameraToMyLocation(Position position) async {
    final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
      target: NLatLng(position.latitude, position.longitude),
      zoom: _defaultZoom,
    );
    _naverMapController.updateCamera(cameraUpdate);
  }

  // 마커 업데이트
  Future<void> _updateMapMarkers() async {
    final overlays = <NMarker>[];
    for (final item in _mapController.nearbyPoiItems) {
      final iconPath = _getIconPath(item.category);
      final icon = await _getIconImage(iconPath);

      overlays.add(
        NMarker(
          id: item.id,
          position: NLatLng(item.lat, item.lng),
          icon: icon,
          size: const NSize(31.5, 41.5),
        ),
      );
    }

    _naverMapController.clearOverlays();
    _naverMapController.addOverlayAll(overlays.toSet());
  }

  Future<void> _getPoiItemsAndUpdateMarkers({
    required double lat,
    required double lng,
    double? zoom,
  }) async {
    await _mapController.updateNearbyPoiItems(lat: lat, lng: lng, zoom: zoom);
    await _updateMapMarkers();
  }

  // 지도 준비 완료 시 실행
  void _onMapReady(NaverMapController controller) async {
    _naverMapController = controller;
    _naverMapController.clearOverlays();

    requestGeolocationPermission()
        .then((isGranted) async {
          if (isGranted) {
            _naverMapController.setLocationTrackingMode(
              NLocationTrackingMode.follow,
            );

            Position position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best,
              ),
            );

            // 내 위치로 카메라 이동
            _moveCameraToMyLocation(position);

            log('position: $position');
            await _getPoiItemsAndUpdateMarkers(
              lat: position.latitude,
              lng: position.longitude,
              zoom: _defaultZoom,
            );
          }

          setState(() {
            isMapReady = true;
            showSearchButton = false;
          });
        })
        .catchError((error) {
          log('error: $error');
        });
  }

  // 카메라 이동 종료 시 실행
  Future<void> _onCameraIdle() async {
    if (!isMapReady) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      log('onCameraIdle');
      setState(() {
        showSearchButton = true;
      });
    });
  }

  // 이 지역 검색하기 버튼 클릭
  Future<void> _onSearchButtonTap() async {
    final cameraPosition = await _naverMapController.getCameraPosition();

    await _getPoiItemsAndUpdateMarkers(
      lat: cameraPosition.target.latitude,
      lng: cameraPosition.target.longitude,
      zoom: cameraPosition.zoom,
    );
    setState(() {
      showSearchButton = false;
    });
  }

  // 내 위치로 이동 버튼 클릭
  Future<void> _onMyLocationButtonPressed() async {
    // 현재 내 위치 가져오기
    final position = await Geolocator.getCurrentPosition();

    // 내 위치 주변 아이템 업데이트
    await _getPoiItemsAndUpdateMarkers(
      lat: position.latitude,
      lng: position.longitude,
      zoom: _defaultZoom,
    );

    // 내 위치로 카메라 이동
    _moveCameraToMyLocation(position);

    setState(() {
      showSearchButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 20,
            ),
            child: SearchBox(
              onChanged: (value) {
                // TODO: 검색 기능 구현
                print('검색어: $value');
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // 지도
                NaverMap(
                  options: const NaverMapViewOptions(),
                  onMapReady: _onMapReady,
                  onCameraIdle: _onCameraIdle,
                ),
                // 카테고리
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mapController.poiCategories.length,
                      itemBuilder: (context, index) {
                        final category = _mapController.poiCategories[index];
                        final isSelected = selectedCategoryId == category.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedCategoryId = null;
                                } else {
                                  selectedCategoryId = category.id;
                                }
                              });
                            },
                            child: Chip(
                              label: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor:
                                  isSelected
                                      ? const Color(0xFF65C466)
                                      : Colors.white,
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? const Color(0xFF65C466)
                                        : const Color(0xFFE5E5E5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 이 지역 검색하기 버튼
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: showSearchButton ? 60 : -60,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showSearchButton ? 1.0 : 0.0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _onSearchButtonTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '이 지역 검색하기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 내 위치로 이동 버튼
                Positioned(
                  bottom: 120,
                  right: 16,
                  child: SlideTransition(
                    position: SheetOffsetDrivenAnimation(
                      controller: _sheetController,
                      initialValue: 0,
                    ).drive(
                      Tween(begin: Offset(0, 1.1), end: const Offset(0, -8)),
                    ),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: _onMyLocationButtonPressed,
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF65C466),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // 바텀 시트
                SheetViewport(
                  child: _MySheet(
                    items: _mapController.nearbyPoiItems,
                    controller: _sheetController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> requestGeolocationPermission() async {
  final response = await Permission.location.request();

  return response.isGranted;
}

class _MySheet extends StatelessWidget {
  final List<PoiItem> items;
  final SheetController controller;

  const _MySheet({required this.items, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final minOffset = SheetOffset.absolute(56 + bottomPadding);

    return Sheet(
      controller: controller,
      initialOffset: SheetOffset.absolute(56 + bottomPadding),
      dragConfiguration: SheetDragConfiguration(),
      decoration: MaterialSheetDecoration(
        size: SheetSize.stretch,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
        elevation: 4,
      ),
      snapGrid: SheetSnapGrid(
        snaps: [minOffset, const SheetOffset(0.5), const SheetOffset(0.83)],
      ),
      scrollConfiguration: const SheetScrollConfiguration(),
      child: Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: const _ContentSheetHandle().preferredSize.height,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return PoiListItem(item: items[index]);
            },
          ),
          GestureDetector(
            onTap: () {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: _ContentSheetHandle(),
          ),
        ],
      ),
    );
  }
}

class _ContentSheetHandle extends StatelessWidget
    implements PreferredSizeWidget {
  const _ContentSheetHandle();

  @override
  Size get preferredSize => const Size.fromHeight(46);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox.fromSize(
        size: preferredSize,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [buildIndicator(), const SizedBox(height: 16)],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return Container(
      height: 6,
      width: 40,
      decoration: const ShapeDecoration(
        color: Colors.black12,
        shape: StadiumBorder(),
      ),
    );
  }
}
