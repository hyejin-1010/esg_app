import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:esg_app/models/map_model.dart';
import 'package:esg_app/controllers/map_controller.dart';

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
  bool isDevCameraChange = false;
  int? selectedMarkerIndex;
  final ScrollController _scrollController = ScrollController();

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

    setState(() {
      isDevCameraChange = true;
    });
  }

  // 마커 업데이트
  Future<void> _updateMapMarkers() async {
    final overlays = <NMarker>[];
    for (int i = 0; i < _mapController.nearbyPoiItems.length; i++) {
      final item = _mapController.nearbyPoiItems[i];
      final iconPath = _getIconPath(item.category);
      final icon = await _getIconImage(iconPath);

      final marker = NMarker(
        id: item.id,
        position: NLatLng(item.lat, item.lng),
        icon: icon,
        size: const NSize(31.5, 41.5),
      );

      marker.setOnTapListener((overlay) {
        setState(() {
          selectedMarkerIndex = i;
        });
        _sheetController.animateTo(const SheetOffset(0.5));
        _scrollToSelectedItem();
      });

      overlays.add(marker);
    }

    _naverMapController.clearOverlays();
    _naverMapController.addOverlayAll(overlays.toSet());
  }

  void _scrollToSelectedItem() {
    if (selectedMarkerIndex == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // 바텀 시트를 50% 위치로 이동
        _sheetController.animateTo(const SheetOffset(0.5)).then((_) {
          // 바텀 시트 이동이 완료된 후 스크롤 위치 조정
          Future.delayed(const Duration(milliseconds: 100), () {
            final context =
                _scrollController.position.context.notificationContext!;
            final position = _MySheet(
              items: _mapController.nearbyPoiItems,
              controller: _sheetController,
              scrollController: _scrollController,
              selectedIndex: selectedMarkerIndex,
            )._calculateItemPosition(context, selectedMarkerIndex!);

            // 스크롤 위치 조정
            _scrollController
                .animateTo(
                  position,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
                .then((_) {
                  // 애니메이션 실행
                  setState(() {
                    final currentIndex = selectedMarkerIndex;
                    selectedMarkerIndex = null;
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) {
                        setState(() {
                          selectedMarkerIndex = currentIndex;
                        });
                      }
                    });
                  });
                });
          });
        });
      }
    });
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

            await _getPoiItemsAndUpdateMarkers(
              lat: position.latitude,
              lng: position.longitude,
              zoom: _defaultZoom,
            );
          }

          setState(() {
            isMapReady = true;
            isDevCameraChange = true;
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

    log('isDevCameraChange: $isDevCameraChange');

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (isDevCameraChange) {
          showSearchButton = false;
        } else {
          showSearchButton = true;
        }

        isDevCameraChange = false;
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
    try {
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
        isDevCameraChange = true;
        showSearchButton = false;
      });
    } catch (error) {
      // 내 위치 권한 거부 된 경우 앱 설정으로 이동
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('내 위치 권한 거부'),
                content: const Text('내 위치 권한을 허용해주세요.'),
                actions: [
                  TextButton(
                    onPressed: () => Geolocator.openAppSettings(),
                    child: const Text('설정으로 이동'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // 카테고리 선택
  Future<void> _onCategoryTap(bool isSelected, int categoryId) async {
    final cameraPosition = await _naverMapController.getCameraPosition();

    await _mapController.filterCategory(
      categoryId: selectedCategoryId == categoryId ? null : categoryId,
      lat: cameraPosition.target.latitude,
      lng: cameraPosition.target.longitude,
      zoom: cameraPosition.zoom,
    );

    await _updateMapMarkers();

    setState(() {
      if (isSelected) {
        selectedCategoryId = null;
      } else {
        selectedCategoryId = categoryId;
      }

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
              onChanged: (value) {},
              onSubmitted: (value) async {
                final cameraPosition =
                    await _naverMapController.getCameraPosition();
                await _mapController.searchPoiItems(
                  query: value,
                  lat: cameraPosition.target.latitude,
                  lng: cameraPosition.target.longitude,
                  zoom: cameraPosition.zoom,
                );
                await _updateMapMarkers();

                // 검색 결과가 있으면 검색 결과 중심으로 카메라 이동
                if (_mapController.nearbyPoiItems.isNotEmpty) {
                  final latLngs =
                      _mapController.nearbyPoiItems
                          .map((e) => NLatLng(e.lat, e.lng))
                          .toList();
                  final bounds = NLatLngBounds.from(latLngs);
                  final cameraUpdate = NCameraUpdate.fitBounds(
                    bounds,
                    padding: const EdgeInsets.all(50),
                  );
                  _naverMapController.updateCamera(cameraUpdate);

                  setState(() {
                    selectedCategoryId = null;
                    isDevCameraChange = true;
                  });
                }
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
                            onTap:
                                () => _onCategoryTap(isSelected, category.id),
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
                    scrollController: _scrollController,
                    selectedIndex: selectedMarkerIndex,
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
  final ScrollController scrollController;
  final int? selectedIndex;

  const _MySheet({
    required this.items,
    required this.controller,
    required this.scrollController,
    this.selectedIndex,
  });

  // 아이템의 실제 위치를 계산하는 메서드 수정
  double _calculateItemPosition(BuildContext context, int index) {
    // 각 아이템의 기본 높이 (패딩 포함)
    const double itemHeight = 130.0; // 기본 높이
    const double handleHeight = 46.0; // 바텀 시트 핸들 높이

    // 선택된 아이템의 위치 계산
    double position = index * itemHeight;

    // 바텀 시트의 현재 높이 계산 (50% 위치 기준)
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.5; // 50% 위치의 높이
    final searchBarHeight = 80.0;

    // 아이템이 바텀 시트의 중앙에 오도록 조정
    // 바텀 시트의 핸들 높이를 고려하여 위치 조정
    position =
        position - (bottomSheetHeight / 2) + handleHeight + searchBarHeight;

    return position;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final minOffset = SheetOffset.absolute(56 + bottomPadding);
    final screenHeight = MediaQuery.of(context).size.height;

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
        // snaps: [minOffset, const SheetOffset(0.5), const SheetOffset(0.83)],
        snaps: [minOffset, const SheetOffset(0.5), const SheetOffset(0.83)],
      ),
      scrollConfiguration: const SheetScrollConfiguration(),
      child: Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: const _ContentSheetHandle().preferredSize.height,
              bottom: screenHeight * 0.5, // 바텀시트가 50% 위치일 때의 높이만큼 패딩 추가
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return PoiListItem(
                item: items[index],
                isSelected: index == selectedIndex,
              );
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
