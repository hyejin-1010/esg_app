import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'find_detail.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  @override
  Widget build(BuildContext context) {
    // 매거진 배열
    final List<String> magazineImages = [
      'assets/images/find/magazine1.png',
      'assets/images/find/magazine2.png',
      'assets/images/find/magazine3.png',
      'assets/images/find/magazine4.png',
    ];

    final List<Map<String, String>> newsList = [
      {
        'image': 'assets/images/find/news1.png',
        'url': 'https://www.electimes.com/news/articleView.html?idxno=352263',
      },
      {
        'image': 'assets/images/find/news2.png',
        'url': 'https://naver.me/5S9Nm1Z3',
      },
    ];

    final List<Map<String, String>> storeList = [
      {
        'id':'1',
        'image': 'assets/images/find/find1.png',
        'nameEn': 'Earth Us',
        'nameKo': '얼스어스',
        'description': '제로웨이스트를 실천하는 친환경 연남동 카페\n\n'
            '🌐 주소 : 서울 마포구 성미산로 150\n'
            '🕤 영업시간 : 수~월 12:00-21:00(매주 화요일 휴무)\n'
            '☎️ 전화번호 : 0507.1341.9413\n',
        'tag': '제로웨이스트·일회용품 없는 카페',
      },
      {
        'id':'2',
        'image': 'assets/images/find/find2.png',
        'nameEn': 'URBAN LAUNDERETTE THE TERRACE',
        'nameKo': '어반런드렛 더 테라스',
        'description': '친환경 세탁소와 건강한 음료, 디저트를 제공하는 이색 카페\n\n'
            '🌐 주소 : 경기 용인시 기흥구 용구대로2469번길 47 1층\n'
            '🕤 영업시간 : 매일 09:00 ~ 01:00\n'
            '☎️ 전화번호 : 031-261-8725\n',
        'tag': '친환경·웻클리닝',
      },
      {
        'id':'3',
        'image': 'assets/images/find/find3.png',
        'nameEn': 'Bottle Lounge',
        'nameKo': '보틀라운지 연희점',
        'description': '연희동 제로웨이스트&비건 카페\n\n'
            '🌐 주소 : 서울 서대문구 홍연길 26\n'
            '🕤 영업시간 : 매일 11:30-21:00\n'
            '☎️ 전화번호 : 02-3144-0703\n',
        'tag': '제로웨이스트·비건',
      },
      {
        'id':'4',
        'image': 'assets/images/find/find4.png',
        'nameEn': 'ZERO WASTE SHOP',
        'nameKo': '지구인상점',
        'description': '남양주 친환경 생활용품점\n\n'
            '🌐 주소 : 경기 남양주시 다산중앙로123번길 29 단지내 상가 106호\n'
            '🕤 영업시간 : 화~토 12:00-20:00 (매주 월, 일 휴무)\n'
            '☎️ 전화번호 : 0507-1335-0554\n',
        'tag': '제로웨이스트·친환경생활용품점·자원순환',
      },
      {
        'id':'5',
        'image': 'assets/images/find/find5.png',
        'nameEn': 'VEGAN VEGANING',
        'nameKo': '비건비거닝',
        'description': '강남 선릉역에 위치한 비건빵, 비건요거트 맛집\n\n'
            '🌐 주소 : 서울 강남구 선릉로85길 6 호텔뉴브 1층\n'
            '🕤 영업시간 : 월~토 08:00-19:00 (매주 일요일 휴무)\n'
            '☎️ 전화번호 : 0507-2085-1426\n',
        'tag': '채식 음식점',
      }
    ];

    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // HOT 매장 반복
                  ...storeList.map((store) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 500,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Image.asset(
                                store['image']!,
                                width: double.infinity,
                                height: 500,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'HOT 매장',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  color: Colors.black,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        store['nameEn']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        store['nameKo']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        store['tag']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FindDetailPopup(
                                                id: store['id']!,
                                                nameEn: store['nameEn']!,
                                                nameKo: store['nameKo']!,
                                                description: store['description']!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('더보기'),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // 매거진 카드 반복
                  ...magazineImages.map((imagePath) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 400,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                Image.asset(
                                  imagePath,
                                  width: double.infinity,
                                  height: 400,
                                  fit: BoxFit.fill,
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '매거진',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                  // 뉴스 반복
                  ...newsList.map((news) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 500,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(news['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'NEWS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse(news['url']!);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '기사 원문 보기',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ],
              ),
            )
        )
    );
  }
}