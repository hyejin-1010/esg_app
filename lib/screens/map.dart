import 'package:esg_app/controllers/map_controller.dart';
import 'package:esg_app/models/map_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'dart:async';

import '../components/mission/search_box.dart';
import '../components/map/poi_list_item.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<PoiCategory> poiCategories = [];
  final MapController _mapController = Get.find<MapController>();
  int? selectedCategoryId;
  Timer? _debounceTimer;
  bool showSearchButton = false;

  @override
  void initState() {
    super.initState();

    // TODO: 위치 권한 요청
    // try {
    //   requestGeolocationPermission();
    // } catch (error) {
    //   print('error: $error');
    // }

    _loadPoiCategories();
    _loadPoiItems();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadPoiCategories() async {
    await _mapController.loadPoiCategories();

    setState(() {
      poiCategories = _mapController.poiCategories;
    });
  }

  void _loadPoiItems() async {
    await _mapController.loadPoiItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                NaverMap(
                  options: const NaverMapViewOptions(),
                  onCameraChange: (reason, animated) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(
                      const Duration(milliseconds: 200),
                      () {
                        setState(() {
                          showSearchButton = true;
                        });
                      },
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: poiCategories.length,
                      itemBuilder: (context, index) {
                        final category = poiCategories[index];
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
                        onTap: () {
                          setState(() {
                            showSearchButton = false;
                          });
                        },
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
                SheetViewport(child: _MySheet(items: _mapController.poiItems)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> requestGeolocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

  // Test if location services are enabled.
  serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
  print('serviceEnabled: $serviceEnabled');

  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await geolocatorPlatform.checkPermission();
  print('permission: $permission');

  if (permission == LocationPermission.denied) {
    permission = await geolocatorPlatform.requestPermission();
    print('permission request: $permission');

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }
}

class _MySheet extends StatelessWidget {
  final List<PoiItem> items;

  const _MySheet({required this.items});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Sheet(
      dragConfiguration: SheetDragConfiguration(),
      decoration: MaterialSheetDecoration(
        size: SheetSize.stretch,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
        elevation: 4,
      ),
      snapGrid: const SheetSnapGrid(
        snaps: [SheetOffset(0.1), SheetOffset(0.5), SheetOffset(0.83)],
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
