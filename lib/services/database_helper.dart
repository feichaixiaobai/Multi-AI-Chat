import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 对话表
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 消息表
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        content TEXT NOT NULL,
        isUser INTEGER NOT NULL,
        model INTEGER,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (conversationId) REFERENCES conversations (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('''
      CREATE INDEX idx_messages_conversation 
      ON messages(conversationId, timestamp)
    ''');
  }

  // ==================== 对话操作 ====================

  // 创建新对话
  Future<Conversation> createConversation(String title) async {
    final db = await database;
    final now = DateTime.now();

    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('conversations', {
      'id': conversation.id,
      'title': conversation.title,
      'createdAt': conversation.createdAt.toIso8601String(),
      'updatedAt': conversation.updatedAt.toIso8601String(),
    });

    return conversation;
  }

  // 获取所有对话（按更新时间倒序）
  Future<List<Conversation>> getAllConversations() async {
    final db = await database;
    final conversationMaps = await db.query(
      'conversations',
      orderBy: 'updatedAt DESC',
    );

    List<Conversation> conversations = [];
    for (var convMap in conversationMaps) {
      final messages = await getMessages(convMap['id'] as String);
      conversations.add(Conversation(
        id: convMap['id'] as String,
        title: convMap['title'] as String,
        messages: messages,
        createdAt: DateTime.parse(convMap['createdAt'] as String),
        updatedAt: DateTime.parse(convMap['updatedAt'] as String),
      ));
    }

    return conversations;
  }

  // 获取单个对话
  Future<Conversation?> getConversation(String id) async {
    final db = await database;
    final maps = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final convMap = maps.first;
    final messages = await getMessages(id);

    return Conversation(
      id: convMap['id'] as String,
      title: convMap['title'] as String,
      messages: messages,
      createdAt: DateTime.parse(convMap['createdAt'] as String),
      updatedAt: DateTime.parse(convMap['updatedAt'] as String),
    );
  }

  // 更新对话标题
  Future<void> updateConversationTitle(String id, String newTitle) async {
    final db = await database;
    await db.update(
      'conversations',
      {
        'title': newTitle,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除对话（级联删除消息）
  Future<void> deleteConversation(String id) async {
    final db = await database;
    await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
    // 消息会因为外键约束自动删除
    await db.delete(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [id],
    );
  }

  // ==================== 消息操作 ====================

  // 添加消息
  Future<void> insertMessage(String conversationId, Message message) async {
    final db = await database;

    await db.insert('messages', {
      'id': message.id,
      'conversationId': conversationId,
      'content': message.content,
      'isUser': message.isUser ? 1 : 0,
      'model': message.model?.index,
      'timestamp': message.timestamp.toIso8601String(),
    });

    // 更新对话的 updatedAt
    await db.update(
      'conversations',
      {'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  // 获取对话的所有消息
  Future<List<Message>> getMessages(String conversationId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) {
      return Message(
        id: map['id'] as String,
        content: map['content'] as String,
        isUser: (map['isUser'] as int) == 1,
        model: map['model'] != null
            ? AIModel.values[map['model'] as int]
            : null,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    }).toList();
  }

  // 删除消息
  Future<void> deleteMessage(String messageId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  // 清空对话的所有消息
  Future<void> clearMessages(String conversationId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
    );
  }

  // ==================== 搜索功能 ====================

  // 搜索消息
  Future<List<Message>> searchMessages(String keyword) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'content LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) {
      return Message(
        id: map['id'] as String,
        content: map['content'] as String,
        isUser: (map['isUser'] as int) == 1,
        model: map['model'] != null
            ? AIModel.values[map['model'] as int]
            : null,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    }).toList();
  }

  // ==================== 工具方法 ====================

  // 获取对话数量
  Future<int> getConversationCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM conversations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 获取消息数量
  Future<int> getMessageCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM messages');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}