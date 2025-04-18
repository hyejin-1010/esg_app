class Mission {
  final int id;
  final String title;
  final String description;
  final int reward;
  final String iconName;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.iconName,
  });

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      iconName: map['icon_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'icon_name': iconName,
    };
  }
}
