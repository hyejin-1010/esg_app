class AuthDao {
  static final AuthDao _instance = AuthDao._internal();
  factory AuthDao() => _instance;
  AuthDao._internal();

  Future<Database> get _db async => await DBHelper.database;

  Future<int> getReward(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'Auth',
      columns: ['reward'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return 0;
    return maps.first['reward'] as int;
  }

  Future<String?> getNicknameByUserId(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'Auth',
      columns: ['nickname'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return maps.first['nickname'] as String?;
  }
} 