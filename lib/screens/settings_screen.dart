import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import '../config/api_config.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              // 主题设置
              SwitchListTile(
                title: const Text('深色模式'),
                subtitle: const Text('切换应用主题'),
                value: settings.isDarkMode,
                onChanged: (_) => settings.toggleDarkMode(),
                secondary: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              const Divider(),

              // API密钥配置说明
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '应用已内置默认API密钥，可直接使用。\n如需使用自己的密钥，请在下方配置。',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // API密钥配置
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'API密钥配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _buildApiKeyTile(
                context: context,
                title: 'DeepSeek API Key',
                icon: Icons.psychology,
                color: Colors.purple,
                currentKey: settings.deepseekApiKey,
                isUsingDefault: settings.isUsingDefaultDeepSeek(),
                hasValidKey: settings.hasValidDeepSeekKey(),
                onSave: settings.setDeepSeekApiKey,
                onClear: settings.clearDeepSeekApiKey,
              ),

              _buildApiKeyTile(
                context: context,
                title: 'OpenAI API Key',
                icon: Icons.smart_toy,
                color: Colors.green,
                currentKey: settings.openaiApiKey,
                isUsingDefault: settings.isUsingDefaultOpenAI(),
                hasValidKey: settings.hasValidOpenAIKey(),
                onSave: settings.setOpenAIApiKey,
                onClear: settings.clearOpenAIApiKey,
              ),

              _buildApiKeyTile(
                context: context,
                title: 'Gemini API Key',
                icon: Icons.auto_awesome,
                color: Colors.blue,
                currentKey: settings.geminiApiKey,
                isUsingDefault: settings.isUsingDefaultGemini(),
                hasValidKey: settings.hasValidGeminiKey(),
                onSave: settings.setGeminiApiKey,
                onClear: settings.clearGeminiApiKey,
              ),

              _buildApiKeyTile(
                context: context,
                title: 'Grok API Key',
                icon: Icons.rocket_launch,
                color: Colors.orange,
                currentKey: settings.grokApiKey,
                isUsingDefault: settings.isUsingDefaultGrok(),
                hasValidKey: settings.hasValidGrokKey(),
                onSave: settings.setGrokApiKey,
                onClear: settings.clearGrokApiKey,
              ),

              _buildApiKeyTile(
                context: context,
                title: '豆包 API Key',
                icon: Icons.coffee,
                color: Colors.teal,
                currentKey: settings.doubaoApiKey,
                isUsingDefault: settings.isUsingDefaultDoubao(),
                hasValidKey: settings.hasValidDoubaoKey(),
                onSave: settings.setDoubaoApiKey,
                onClear: settings.clearDoubaoApiKey,
              ),

              _buildApiKeyTile(
                context: context,
                title: 'Claude API Key',
                icon: Icons.ac_unit,
                color: Colors.brown,
                currentKey: settings.claudeApiKey,
                isUsingDefault: settings.isUsingDefaultClaude(),
                hasValidKey: settings.hasValidClaudeKey(),
                onSave: settings.setClaudeApiKey,
                onClear: settings.clearClaudeApiKey,
              ),

              const Divider(),

              // 关于信息 - 改为可点击
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于'),
                subtitle: const Text('Multi AI Chat v1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildApiKeyTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String currentKey,
    required bool isUsingDefault,
    required bool hasValidKey,
    required Future<void> Function(String) onSave,
    required Future<void> Function() onClear,
  }) {
    String statusText;
    Color statusColor;

    if (!hasValidKey) {
      statusText = '未配置';
      statusColor = Colors.red;
    } else if (isUsingDefault) {
      statusText = '使用默认密钥';
      statusColor = Colors.blue;
    } else {
      statusText = '自定义 (${currentKey.substring(0, 8)}...)';
      statusColor = Colors.green;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
          ),
          if (isUsingDefault)
            const Text(
              '点击可配置自己的密钥',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentKey.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => _showClearDialog(context, title, onClear),
              tooltip: '清除自定义密钥',
            ),
          const Icon(Icons.edit),
        ],
      ),
      onTap: () {
        _showApiKeyDialog(
          context: context,
          title: title,
          currentKey: currentKey,
          onSave: onSave,
          isUsingDefault: isUsingDefault,
        );
      },
    );
  }

  void _showApiKeyDialog({
    required BuildContext context,
    required String title,
    required String currentKey,
    required Future<void> Function(String) onSave,
    required bool isUsingDefault,
  }) {
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('配置 $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUsingDefault) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '当前使用默认密钥',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: isUsingDefault ? '输入自定义密钥（可选）' : '输入API密钥',
                border: const OutlineInputBorder(),
                helperText: '留空将使用默认密钥',
                helperMaxLines: 2,
              ),
              obscureText: true,
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await onSave(controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.text.trim().isEmpty
                          ? 'API密钥已清除，将使用默认密钥'
                          : 'API密钥已保存',
                    ),
                  ),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(
      BuildContext context,
      String title,
      Future<void> Function() onClear,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除自定义密钥'),
        content: Text('确定要清除 $title 的自定义配置吗？\n\n将恢复使用默认密钥。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await onClear();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已恢复使用默认密钥')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}