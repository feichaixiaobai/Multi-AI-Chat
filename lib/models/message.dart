import 'package:flutter/material.dart';

enum AIModel {
  deepseek,
  chatgpt,
  gemini,
  grok,
  doubao,
  claude,
}

extension AIModelExtension on AIModel {
  String get name {
    switch (this) {
      case AIModel.deepseek:
        return 'DeepSeek';
      case AIModel.chatgpt:
        return 'ChatGPT';
      case AIModel.gemini:
        return 'Gemini';
      case AIModel.grok:
        return 'Grok';
      case AIModel.doubao:
        return 'Doubao';
      case AIModel.claude:
        return 'Claude';
    }
  }

  String get displayName {
    switch (this) {
      case AIModel.deepseek:
        return 'DeepSeek';
      case AIModel.chatgpt:
        return 'GPT-4';
      case AIModel.gemini:
        return 'Gemini Pro';
      case AIModel.grok:
        return 'Grok';
      case AIModel.doubao:
        return '豆包';
      case AIModel.claude:
        return 'Claude';
    }
  }

  Color get color {
    switch (this) {
      case AIModel.deepseek:
        return Colors.purple;
      case AIModel.chatgpt:
        return Colors.green;
      case AIModel.gemini:
        return Colors.blue;
      case AIModel.grok:
        return Colors.orange;
      case AIModel.doubao:
        return Colors.teal;
      case AIModel.claude:
        return Colors.brown;
    }
  }
}

class Message {
  final String id;
  final String content;
  final bool isUser;
  final AIModel? model;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    this.model,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'model': model?.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      model: json['model'] != null ? AIModel.values[json['model']] : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}