import 'package:esg_app/components/feed_item.dart';
import 'package:esg_app/controllers/feed_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FeedController feedController = Get.find();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    try {
      await feedController.loadItems();
      setState(() {});
    } catch (e) {
      debugPrint('[ERROR] FeedScreen: _getData() error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset(
          'assets/images/green_earth.png',
          width: 150,
          fit: BoxFit.cover,
        ),
        leading: Container(),
        leadingWidth: 0,
      ),
      body: ListView.builder(
        itemCount: feedController.items.length,
        itemBuilder: (context, index) {
          return FeedItem(
            feed: feedController.items[index],
            onFavoriteTap: () async {
              await feedController.toggleFavorite(
                feedController.items[index].id!,
              );
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
