import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/database_helper.dart';

class ChatProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  AIModel _selectedModel = AIModel.chatgpt;
  bool _isLoading = false;

  // 流式响应的临时消息
  Message? _streamingMessage;

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  List<Message> get messages {
    final msgs = _currentConversation?.messages ?? [];
    // 如果有流式消息，添加到末尾
    if (_streamingMessage != null) {
      return [...msgs, _streamingMessage!];
    }
    return msgs;
  }
  AIModel get selectedModel => _selectedModel;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await loadConversations();
  }

  Future<void> loadConversations() async {
    _conversations = await _dbHelper.getAllConversations();
    notifyListeners();
  }

  Future<void> createNewConversation() async {
    final title = '新对话 ${DateTime.now().month}/${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}';
    final conversation = await _dbHelper.createConversation(title);

    _conversations.insert(0, conversation);
    _currentConversation = conversation;
    notifyListeners();
  }

  Future<void> selectConversation(String conversationId) async {
    _currentConversation = await _dbHelper.getConversation(conversationId);
    _streamingMessage = null; // 清除流式消息
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    await _dbHelper.deleteConversation(conversationId);
    _conversations.removeWhere((c) => c.id == conversationId);

    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
      _streamingMessage = null;
    }

    notifyListeners();
  }

  Future<void> renameConversation(String conversationId, String newTitle) async {
    await _dbHelper.updateConversationTitle(conversationId, newTitle);

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = Conversation(
        id: _conversations[index].id,
        title: newTitle,
        messages: _conversations[index].messages,
        createdAt: _conversations[index].createdAt,
        updatedAt: DateTime.now(),
      );
    }

    if (_currentConversation?.id == conversationId) {
      _currentConversation = await _dbHelper.getConversation(conversationId);
    }

    notifyListeners();
  }

  void setModel(AIModel model) {
    _selectedModel = model;
    notifyListeners();
  }

  void setApiKeys({
    String? deepseek,
    String? openai,
    String? gemini,
    String? grok,
    String? doubao,
    String? claude,
  }) {
    if (deepseek != null) _aiService.deepseekApiKey = deepseek;
    if (openai != null) _aiService.openaiApiKey = openai;
    if (gemini != null) _aiService.geminiApiKey = gemini;
    if (grok != null) _aiService.grokApiKey = grok;
    if (doubao != null) _aiService.doubaoApiKey = doubao;
    if (claude != null) _aiService.claudeApiKey = claude;
  }

  // 流式发送消息
  Future<void> sendMessageStream(String content) async {
    if (content.trim().isEmpty) return;

    // 如果没有当前对话,创建一个新对话
    if (_currentConversation == null) {
      await createNewConversation();
    }

    // 添加用户消息
    final userMessage = Message(
      id: const Uuid().v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _currentConversation!.messages.add(userMessage);
    await _dbHelper.insertMessage(_currentConversation!.id, userMessage);
    notifyListeners();

    // 创建流式消息占位符
    final aiMessageId = const Uuid().v4();
    _streamingMessage = Message(
      id: aiMessageId,
      content: '',
      isUser: false,
      model: _selectedModel,
      timestamp: DateTime.now(),
    );

    // 开始加载
    _isLoading = true;
    notifyListeners();

    try {
      // 流式接收AI响应
      final stream = _aiService.sendMessageStream(
        _selectedModel,
        _currentConversation!.messages,
      );

      await for (var chunk in stream) {
        // 累加内容
        _streamingMessage = Message(
          id: _streamingMessage!.id,
          content: _streamingMessage!.content + chunk,
          isUser: false,
          model: _selectedModel,
          timestamp: _streamingMessage!.timestamp,
        );
        notifyListeners();
      }

      // 流式响应完成，保存到数据库
      if (_streamingMessage != null && _streamingMessage!.content.isNotEmpty) {
        _currentConversation!.messages.add(_streamingMessage!);
        await _dbHelper.insertMessage(_currentConversation!.id, _streamingMessage!);

        // 更新对话列表
        final index = _conversations.indexWhere((c) => c.id == _currentConversation!.id);
        if (index != -1) {
          _conversations[index] = _currentConversation!;
          final conv = _conversations.removeAt(index);
          _conversations.insert(0, conv);
        }
      }

    } catch (e) {
      // 添加错误消息
      final errorMessage = Message(
        id: const Uuid().v4(),
        content: '发送失败: $e',
        isUser: false,
        model: _selectedModel,
        timestamp: DateTime.now(),
      );
      _currentConversation!.messages.add(errorMessage);
      await _dbHelper.insertMessage(_currentConversation!.id, errorMessage);
    } finally {
      _streamingMessage = null; // 清除流式消息
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCurrentMessages() async {
    if (_currentConversation == null) return;

    await _dbHelper.clearMessages(_currentConversation!.id);
    _currentConversation!.messages.clear();
    _streamingMessage = null;
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId) async {
    if (_currentConversation == null) return;

    await _dbHelper.deleteMessage(messageId);
    _currentConversation!.messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  Future<List<Message>> searchMessages(String keyword) async {
    return await _dbHelper.searchMessages(keyword);
  }
}