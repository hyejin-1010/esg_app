import 'package:carousel_slider/carousel_slider.dart';
import 'package:esg_app/constant/color.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatefulWidget {
  const FeedItem({super.key, required this.feed});

  final Feed feed;

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  int _currentIndex = 0;

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: Colors.pinkAccent, width: 2.0),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.people),
              ),
              const SizedBox(width: 4.0),
              Text(
                widget.feed.userName,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4.0),
              Text(
                _dateFormat(widget.feed.createdAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: lightGray),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          _buildFeedImages(),
          const SizedBox(height: 4.0),

          Text(
            widget.feed.content,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedImages() {
    return widget.feed.imagePathList.isNotEmpty &&
            widget.feed.imagePathList[0].isNotEmpty
        ? Stack(
          children: [
            CarouselSlider(
              items:
                  widget.feed.imagePathList
                      .map(
                        (item) => Image.network(
                          item,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                      .toList(),
              options: CarouselOptions(
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, _) {
                  _currentIndex = index;
                  setState(() {});
                },
              ),
            ),
            Positioned(
              bottom: 4.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.feed.imagePathList.length,
                  (index) => Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? primaryColor : lightGray,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
        : Container();
  }
}
