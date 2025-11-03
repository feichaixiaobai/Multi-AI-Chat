import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 应用图标
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // 应用名称
            Text(
              'Multi AI Chat',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 版本号
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 应用描述
            Text(
              '集成多个AI模型的智能聊天应用',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 40),

            const Divider(),

            const SizedBox(height: 24),

            // 作者信息卡片
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 作者头像
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 作者名称
                    Text(
                      '㪾夜',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 角色/职位
                    Text(
                      '一名很懒的计算机学生',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // GitHub 链接
                    _buildLinkButton(
                      context: context,
                      icon: Icons.code,
                      label: 'GitHub',
                      url: 'https://github.com/feichaixiaobai',
                      color: Colors.black,
                    ),

                    const SizedBox(height: 12),

                    // 个人网站链接（可选）
                    _buildLinkButton(
                      context: context,
                      icon: Icons.language,
                      label: '个人网站',
                      url: 'https://yblog.15937.top/',
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    // 邮箱链接（可选）

                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 技术栈
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '集成的AI模型',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureChip('DeepSeek', Colors.purple),
                    _buildFeatureChip('ChatGPT', Colors.green),
                    _buildFeatureChip('Gemini', Colors.blue),
                    _buildFeatureChip('Grok', Colors.orange),
                    _buildFeatureChip('豆包', Colors.teal),
                    _buildFeatureChip('Claude', Colors.brown),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 版权信息
            Text(
              '© 2025 Multi AI Chat',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Made with ❤️ using Flutter',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchURL(context, url),
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          side: BorderSide(color: color.withOpacity(0.5)),
          foregroundColor: color,
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),
        label: Text(label),
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide.none,
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法打开链接: $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开链接失败: $e')),
        );
      }
    }
  }
}