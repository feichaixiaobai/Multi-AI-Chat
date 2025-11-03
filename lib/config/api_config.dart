/// API配置类 - 提供默认API和用户自定义API的管理
class APIConfig {
  // 默认API密钥（可以是你自己的，或者留空）
  static const String defaultDeepSeekKey = '';  // 在这里填写你的默认DeepSeek API
  static const String defaultOpenAIKey = '';     // 在这里填写你的默认OpenAI API
  static const String defaultGeminiKey = '';     // 在这里填写你的默认Gemini API
  static const String defaultGrokKey = '';       // 在这里填写你的默认Grok API
  static const String defaultDoubaoKey = '';     // 在这里填写你的默认豆包 API
  static const String defaultClaudeKey = '';     // 在这里填写你的默认Claude API

  // API端点配置（支持自定义后端代理）
  static const String deepseekEndpoint = 'https://api.deepseek.com/v1/chat/completions';
  static const String openaiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1/models/gemini-pro:streamGenerateContent';
  static const String grokEndpoint = 'https://api.x.ai/v1/chat/completions';
  static const String doubaoEndpoint = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
  static const String claudeEndpoint = 'https://api.anthropic.com/v1/messages';

  // 模型配置
  static const Map<String, String> modelConfig = {
    'deepseek': 'deepseek-chat',
    'openai': 'gpt-5',
    'gemini': 'gemini-pro',
    'grok': 'grok-beta',
    'doubao': 'ep-20241102205721-wswsb',  // 豆包模型端点ID
    'claude': 'claude-3-5-sonnet-20241022',
  };

  // 获取有效的API密钥（优先使用用户配置，否则使用默认）
  static String getEffectiveKey(String? userKey, String defaultKey) {
    if (userKey != null && userKey.trim().isNotEmpty) {
      return userKey;
    }
    return defaultKey;
  }

  // 检查是否有可用的API密钥
  static bool hasValidKey(String? userKey, String defaultKey) {
    return getEffectiveKey(userKey, defaultKey).isNotEmpty;
  }

  // 是否使用默认密钥
  static bool isUsingDefaultKey(String? userKey, String defaultKey) {
    return (userKey == null || userKey.trim().isEmpty) && defaultKey.isNotEmpty;
  }
}