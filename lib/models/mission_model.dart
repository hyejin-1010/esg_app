class Mission {
  final int id;
  final String title;
  final String description;
  final int reward;
  final String iconName;
  final int co2; // 탄소 절감량

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.iconName,
    required this.co2,
  });

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      iconName: map['icon_name'],
      co2: map['co2'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'reward': reward,
      'icon_name': iconName,
      'co2': co2,
    };
  }
}
