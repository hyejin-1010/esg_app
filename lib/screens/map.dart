import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import '../components/mission/search_box.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();

    try {
      requestGeolocationPermission();
    } catch (error) {
      print('error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SearchBox(onChanged: (value) {}),
          ),
          const SizedBox(height: 24.0),
          Flexible(
            child: NaverMap(
              options: const NaverMapViewOptions(),
              onMapReady: (controller) {
                print("네이버 맵 로딩됨!");
              },
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
