import 'package:esg_app/controllers/feed_controller.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final feedController = Get.find<FeedController>();
  int _currentIndex = 0;

  int id = 0;
  Feed? feed;

  @override
  void initState() {
    super.initState();
    id = Get.arguments['id'];
    _getData();
  }

  void _getData() async {
    feed = await feedController.loadItem(id);
    if (mounted) setState(() {});
  }

  void _onClickDeleteButton() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text('게시물 삭제'),
            content: Text('게시물을 삭제하시겠습니까?'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              CupertinoDialogAction(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await feedController.deleteItem(id);
                  if (success) {
                    Get.back();
                  } else {
                    Get.snackbar(
                      '게시물 삭제 실패',
                      '게시물 삭제에 실패했습니다.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _onClickMoreButton() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  await Get.toNamed('/editFeed', arguments: {'id': id});
                  _getData();
                },
                child: const Text('수정'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _onClickDeleteButton();
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '게시물',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: _onClickMoreButton,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              feed == null
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      if (feed!.imagePathList.isNotEmpty)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CarouselSlider(
                                items:
                                    feed!.imagePathList
                                        .map(
                                          (item) => Hero(
                                            tag: item,
                                            child: Image.network(
                                              item,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(Icons.error),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                options: CarouselOptions(
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10.0,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    feed!.imagePathList.asMap().entries.map((
                                      entry,
                                    ) {
                                      return GestureDetector(
                                        onTap:
                                            () => print(
                                              'Tapped on indicator ${entry.key}',
                                            ),
                                        child: Container(
                                          width: 8.0,
                                          height: 8.0,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                _currentIndex == entry.key
                                                    ? Colors.white
                                                    : Colors.grey,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            feed!.userName ?? '',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('|', style: TextStyle(color: Colors.grey)),
                          SizedBox(width: 8),
                          Text(
                            feed!.createdAt,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Text(
                          feed!.content,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
