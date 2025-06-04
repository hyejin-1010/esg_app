import 'package:esg_app/models/mission_model.dart';
import 'package:flutter/material.dart';

class MissionItem extends StatelessWidget {
  final Mission mission;
  final VoidCallback onClick;

  const MissionItem({super.key, required this.mission, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 14.0),
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
              'assets/mission/${mission.iconName}',
              width: 35.0,
              height: 35.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(mission.description, style: TextStyle(fontSize: 12)),
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
            onPressed: onClick,
            child: Text(
              '${mission.reward}P 받기',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
