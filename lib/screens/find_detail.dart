import 'package:esg_app/controllers/find_controller.dart';
import 'package:esg_app/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class FindDetailPopup extends StatefulWidget {
  final int id;
  const FindDetailPopup({super.key, required this.id});
  @override
  State<FindDetailPopup> createState() => _FindDetailPopupState();
}

class _FindDetailPopupState extends State<FindDetailPopup> {
  FindController findController = Get.find<FindController>();
  Store? store;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    final store = await findController.getStore(widget.id);
    setState(() {
      this.store = store;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 상단 이미지와 뒤로가기 버튼
            store == null
                ? const SliverToBoxAdapter()
                : SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/find/${store?.thumbnail}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                uri: Uri.parse('https://naver.me/FN7Zth9W'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store?.nameEn ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store?.nameKo ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      store?.description ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'TMI',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: store?.imageList.length ?? 0,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/find/${store?.imageList[index]}',
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
