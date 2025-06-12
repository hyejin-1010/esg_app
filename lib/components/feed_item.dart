import 'package:carousel_slider/carousel_slider.dart';
import 'package:esg_app/constant/color.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatefulWidget {
  const FeedItem({super.key, required this.feed, required this.onFavoriteTap});

  final Feed feed;
  final VoidCallback onFavoriteTap;

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
        mainAxisAlignment: MainAxisAlignment.end,
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
                widget.feed.userName ?? '',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4.0),
              Text(
                _dateFormat(widget.feed.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: lightGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          _buildFeedImages(),
          const SizedBox(height: 4.0),

          Row(
            children: [
              InkWell(
                onTap: widget.onFavoriteTap,
                child: Icon(
                  widget.feed.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                '${widget.feed.favoriteCount}명이 좋아합니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.only(left: 8.0),
            child: RichText(
              text: TextSpan(
                children: _buildTextSpans(widget.feed.content, context),
              ),
            ),
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
                height: 350,
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

  List<TextSpan> _buildTextSpans(String content, BuildContext context) {
    final List<TextSpan> textSpans = [];
    final RegExp hashtagRegExp = RegExp(r'#\S+');
    final defaultStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800);

    int lastIndex = 0;
    for (final match in hashtagRegExp.allMatches(content)) {
      if (match.start > lastIndex) {
        textSpans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: defaultStyle,
          ),
        );
      }

      // Add hashtag with blue color
      textSpans.add(
        TextSpan(
          text: match.group(0),
          style: defaultStyle?.copyWith(color: Colors.blue),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      textSpans.add(
        TextSpan(text: content.substring(lastIndex), style: defaultStyle),
      );
    }

    return textSpans;
  }
}
