import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: message.model?.color ?? Colors.grey,
              radius: 16,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser && message.model != null) ...[
                      Text(
                        message.model!.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: message.model!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Markdown 渲染
                    if (isUser)
                    // 用户消息使用普通文本
                      SelectableText(
                        message.content,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 15,
                        ),
                      )
                    else
                    // AI消息使用Markdown
                      MarkdownBody(
                        data: message.content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                          ),
                          code: TextStyle(
                            backgroundColor: theme.colorScheme.surface,
                            color: theme.colorScheme.primary,
                            fontFamily: 'monospace',
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          codeblockPadding: const EdgeInsets.all(12),
                          blockquote: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border(
                              left: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          h1: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          h2: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          h3: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          listBullet: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          tableBody: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            launchUrl(Uri.parse(href));
                          }
                        },
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: (isUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface)
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 快捷操作按钮
                        InkWell(
                          onTap: () => _copyMessage(context),
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: (isUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface)
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              radius: 16,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareMessage(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      message.content,
      subject: message.model != null
          ? '来自${message.model!.displayName}的回答'
          : '消息分享',
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制消息'),
              onTap: () {
                _copyMessage(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享消息'),
              onTap: () {
                Navigator.pop(context);
                _shareMessage(context);
              },
            ),
            if (!message.isUser) ...[
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('复制代码'),
                subtitle: const Text('提取所有代码块'),
                onTap: () {
                  _copyCodeBlocks(context);
                  Navigator.pop(context);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除消息', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现删除功能（需要从ChatProvider调用）
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copyCodeBlocks(BuildContext context) {
    // 提取所有代码块
    final codeBlockRegex = RegExp(r'```[\s\S]*?```');
    final matches = codeBlockRegex.allMatches(message.content);

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有找到代码块')),
      );
      return;
    }

    final codeBlocks = matches.map((m) {
      String code = m.group(0)!;
      // 移除```标记和语言标识
      code = code.replaceAll(RegExp(r'^```\w*\n?'), '');
      code = code.replaceAll(RegExp(r'\n?```$'), '');
      return code;
    }).join('\n\n---\n\n');

    Clipboard.setData(ClipboardData(text: codeBlocks));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制 ${matches.length} 个代码块')),
    );
  }
}