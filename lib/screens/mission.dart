import 'package:esg_app/db/model_mission_dao.dart';
import 'package:esg_app/models/mission_model.dart';
import 'package:flutter/material.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  List<Mission> missions = [];
  final MissionDao _missionDao = MissionDao();

  @override
  void initState() {
    super.initState();

    _loadMissions();
  }

  void _loadMissions() async {
    final loadedMissions = await _missionDao.getAllItems();
    setState(() {
      missions = loadedMissions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Text(
              '그린미션',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Row(
                spacing: 8.0,
                children: [
                  Icon(Icons.search),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 0.0,
                        ),
                        hintText: '검색어를 입력하세요',
                        hintStyle: TextStyle(color: const Color(0xFFA7AEBC)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            missions.isEmpty
                ? CircularProgressIndicator() // 로딩r 중 표시
                : Expanded(
                  child: ListView.builder(
                    itemCount: missions.length,
                    itemBuilder:
                        (context, index) => Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 14.0,
                          ),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCEDCE8),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F2E6),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                padding: const EdgeInsets.all(7.0),
                                child: Image.asset(
                                  'assets/mission/${missions[index].iconName}',
                                  width: 35.0,
                                  height: 35.0,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    missions[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    missions[index].description,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF65C466),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () {},
                                child: Text(
                                  '${missions[index].reward}P 받기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
