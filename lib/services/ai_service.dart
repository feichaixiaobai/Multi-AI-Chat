import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../config/api_config.dart';

class AIService {
  // API密钥（将由ChatProvider从Settings传入有效密钥）
  String? deepseekApiKey;
  String? openaiApiKey;
  String? geminiApiKey;
  String? grokApiKey;
  String? doubaoApiKey;
  String? claudeApiKey;

  // API端点（使用配置文件中的端点）
  static String get deepseekEndpoint => APIConfig.deepseekEndpoint;
  static String get openaiEndpoint => APIConfig.openaiEndpoint;
  static String get geminiEndpoint => APIConfig.geminiEndpoint;
  static String get grokEndpoint => APIConfig.grokEndpoint;
  static String get doubaoEndpoint => APIConfig.doubaoEndpoint;
  static String get claudeEndpoint => APIConfig.claudeEndpoint;

  // 流式响应
  Stream<String> sendMessageStream(AIModel model, List<Message> messages) async* {
    switch (model) {
      case AIModel.deepseek:
        yield* _sendToDeepSeekStream(messages);
        break;
      case AIModel.chatgpt:
        yield* _sendToChatGPTStream(messages);
        break;
      case AIModel.gemini:
        yield* _sendToGeminiStream(messages);
        break;
      case AIModel.grok:
        yield* _sendToGrokStream(messages);
        break;
      case AIModel.doubao:
        yield* _sendToDoubaoStream(messages);
        break;
      case AIModel.claude:
        yield* _sendToClaudeStream(messages);
        break;
    }
  }

  // 豆包（Doubao）流式响应
  Stream<String> _sendToDoubaoStream(List<Message> messages) async* {
    if (doubaoApiKey == null || doubaoApiKey!.isEmpty) {
      yield '❌ 豆包 API密钥未配置\n\n请在设置中配置API密钥，或使用应用提供的默认密钥';
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(doubaoEndpoint));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $doubaoApiKey',
      });
      request.body = jsonEncode({
        'model': APIConfig.modelConfig['doubao'],
        'messages': _convertMessagesToOpenAIFormat(messages),
        'stream': true,
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (chunk.startsWith('data: ')) {
            final data = chunk.substring(6);
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      } else {
        yield '豆包 API错误: ${response.statusCode}';
      }
    } catch (e) {
      yield '豆包请求失败: $e';
    }
  }

  // Claude 流式响应
  Stream<String> _sendToClaudeStream(List<Message> messages) async* {
    if (claudeApiKey == null || claudeApiKey!.isEmpty) {
      yield '❌ Claude API密钥未配置\n\n请在设置中配置API密钥，或使用应用提供的默认密钥';
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(claudeEndpoint));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'x-api-key': claudeApiKey!,
        'anthropic-version': '2023-06-01',
      });

      // Claude API 需要特殊格式
      final claudeMessages = messages.where((m) => m.isUser || !m.isUser).map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        };
      }).toList();

      request.body = jsonEncode({
        'model': APIConfig.modelConfig['claude'],
        'messages': claudeMessages,
        'max_tokens': 4096,
        'stream': true,
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (chunk.startsWith('data: ')) {
            final data = chunk.substring(6);

            try {
              final json = jsonDecode(data);

              // Claude 流式响应格式
              if (json['type'] == 'content_block_delta') {
                final content = json['delta']?['text'];
                if (content != null) {
                  yield content;
                }
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      } else {
        yield 'Claude API错误: ${response.statusCode}';
      }
    } catch (e) {
      yield 'Claude请求失败: $e';
    }
  }

  // DeepSeek 流式响应
  Stream<String> _sendToDeepSeekStream(List<Message> messages) async* {
    if (deepseekApiKey == null || deepseekApiKey!.isEmpty) {
      yield '❌ DeepSeek API密钥未配置\n\n请在设置中配置API密钥，或使用应用提供的默认密钥';
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(deepseekEndpoint));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $deepseekApiKey',
      });
      request.body = jsonEncode({
        'model': APIConfig.modelConfig['deepseek'],
        'messages': _convertMessagesToOpenAIFormat(messages),
        'temperature': 0.7,
        'stream': true,
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (chunk.startsWith('data: ')) {
            final data = chunk.substring(6);
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      } else {
        yield 'DeepSeek API错误: ${response.statusCode}';
      }
    } catch (e) {
      yield 'DeepSeek请求失败: $e';
    }
  }

  // ChatGPT 流式响应
  Stream<String> _sendToChatGPTStream(List<Message> messages) async* {
    if (openaiApiKey == null || openaiApiKey!.isEmpty) {
      yield '❌ OpenAI API密钥未配置\n\n请在设置中配置API密钥，或使用应用提供的默认密钥';
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(openaiEndpoint));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaiApiKey',
      });
      request.body = jsonEncode({
        'model': APIConfig.modelConfig['openai'],
        'messages': _convertMessagesToOpenAIFormat(messages),
        'temperature': 0.7,
        'stream': true,
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (chunk.startsWith('data: ')) {
            final data = chunk.substring(6);
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      } else {
        yield 'ChatGPT API错误: ${response.statusCode}';
      }
    } catch (e) {
      yield 'ChatGPT请求失败: $e';
    }
  }

  // Gemini 流式响应
  Stream<String> _sendToGeminiStream(List<Message> messages) async* {
    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
      yield '❌ Gemini API密钥未配置\n\n请在设置中配置API密钥，或使用应用提供的默认密钥';
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse('$geminiEndpoint?key=$geminiApiKey&alt=sse'));
      request.headers.addAll({
        'Content-Type': 'application/json',
      });
      request.body = jsonEncode({
        'contents': _convertMessagesToGeminiFormat(messages),
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (chunk.startsWith('data: ')) {
            final data = chunk.substring(6);

            try {
              final json = jsonDecode(data);
              final content = json['candidates']?[0]?['content']?['parts']?[0]?['text'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      } else {
        yield 'Gemini API错误: ${response.statusCode}';
      }
    } catch (e) {
      yield 'Gemini请求失败: $e';
    }
  }

  // Grok 流式响应
  Stream<String> _sendToGrokStream(List<Message> messages) async* {
    if (grokApiKey == null || grokApiKey!.isEmpty) {
      yield '❌ Grok API密钥未配置\n\n请在设置中配置API密钥，或使用应用提供的默认密钥';
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(grokEndpoint));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $grokApiKey',
      });
      request.body = jsonEncode({
        'model': APIConfig.modelConfig['grok'],
        'messages': _convertMessagesToOpenAIFormat(messages),
        'temperature': 0.7,
        'stream': true,
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (chunk.startsWith('data: ')) {
            final data = chunk.substring(6);
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      } else {
        yield 'Grok API错误: ${response.statusCode}';
      }
    } catch (e) {
      yield 'Grok请求失败: $e';
    }
  }

  List<Map<String, String>> _convertMessagesToOpenAIFormat(List<Message> messages) {
    return messages.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _convertMessagesToGeminiFormat(List<Message> messages) {
    return messages.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.content}
        ],
      };
    }).toList();
  }
}