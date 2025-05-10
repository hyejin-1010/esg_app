import 'package:esg_app/components/mission/mission_item.dart';
import 'package:esg_app/components/mission/search_box.dart';
import 'package:esg_app/db/model_mission_dao.dart';
import 'package:esg_app/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  List<Mission> missions = [];
  List<Mission> filteredMissions = [];
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
      filteredMissions = [...missions];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '그린미션',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            SearchBox(
              onChanged: (value) {
                filteredMissions =
                    missions
                        .where((mission) => mission.title.contains(value))
                        .toList();
                setState(() {});
              },
            ),
            const SizedBox(height: 24.0),

            missions.isEmpty
                ? CircularProgressIndicator() // 로딩r 중 표시
                : Expanded(
                  child: ListView.builder(
                    itemCount: filteredMissions.length,
                    itemBuilder: (context, index) {
                      return MissionItem(
                        mission: filteredMissions[index],
                        onClick: () {
                          final id = filteredMissions[index].id;
                          Get.toNamed(
                            '/register-mission',
                            arguments: {'id': id},
                          );
                        },
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
