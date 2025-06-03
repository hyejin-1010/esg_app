import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:esg_app/constant/color.dart';
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

  String _dateFormat(String date) {
    DateTime now = DateTime.now();
    DateTime postDate = DateTime.parse(date);
    Duration difference = now.difference(postDate);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }
    return '${difference.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: feedController.items.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      feedController.items[index].userName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      _dateFormat(feedController.items[index].createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: lightGray),
                    ),
                  ],
                ),

                feedController.items[index].imagePathList.isNotEmpty &&
                        feedController.items[index].imagePathList[0].isNotEmpty
                    ? CarouselSlider(
                      items:
                          feedController.items[index].imagePathList
                              .map(
                                (item) => Image.file(
                                  File(item),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                              .toList(),
                      options: CarouselOptions(
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                      ),
                    )
                    : Container(),

                const SizedBox(height: 4.0),

                Text(
                  feedController.items[index].content,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
