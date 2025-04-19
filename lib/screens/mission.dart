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
    print('heidi test _loadMissions');
    final loadedMissions = await _missionDao.getAllItems();
    setState(() {
      missions = loadedMissions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            missions.isEmpty
                ? CircularProgressIndicator() // 로딩r 중 표시
                : ListView.builder(
                  itemCount: missions.length,
                  itemBuilder: (context, index) => Text(missions[index].title),
                ),
      ),
    );
  }
}
