import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import '../provider/settings_provider.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/model_selector.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化聊天数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    final settings = context.read<SettingsProvider>();

    // 设置API密钥
    chatProvider.setApiKeys(
      deepseek: settings.deepseekApiKey,
      openai: settings.openaiApiKey,
      gemini: settings.geminiApiKey,
      grok: settings.grokApiKey,
    );

    chatProvider.sendMessageStream(content); // 使用流式响应
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return Text(
              chatProvider.currentConversation?.title ?? 'Multi AI Chat',
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        actions: [
          // 重命名对话
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (chatProvider.currentConversation != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showRenameDialog(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // 清空消息
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              if (chatProvider.currentConversation == null) return;

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('清空对话'),
                  content: const Text('确定要清空当前对话的所有消息吗?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        chatProvider.clearCurrentMessages();
                        Navigator.pop(context);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          // 设置
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // 侧边栏 - 对话列表
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '对话历史',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            // 新建对话按钮
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ChatProvider>().createNewConversation();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('新建对话'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const Divider(),
            // 对话列表
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  final conversations = chatProvider.conversations;

                  if (conversations.isEmpty) {
                    return const Center(
                      child: Text('暂无对话历史'),
                    );
                  }

                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      final isSelected = chatProvider.currentConversation?.id == conv.id;

                      return ListTile(
                        selected: isSelected,
                        leading: Icon(
                          Icons.chat,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${conv.messages.length} 条消息',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('删除对话'),
                                content: Text('确定要删除 "${conv.title}" 吗?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      chatProvider.deleteConversation(conv.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          chatProvider.selectConversation(conv.id);
                          Navigator.pop(context);
                          _scrollToBottom();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 模型选择器
          const ModelSelector(),
          const Divider(height: 1),

          // 消息列表
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '开始对话',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '选择AI模型并发送消息',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),

          // 加载指示器
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (chatProvider.isLoading) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            chatProvider.selectedModel.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${chatProvider.selectedModel.displayName} 正在思考...',
                        style: TextStyle(
                          color: chatProvider.selectedModel.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const Divider(height: 1),

          // 输入框
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    return FloatingActionButton(
                      onPressed: chatProvider.isLoading ? null : _sendMessage,
                      child: const Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.currentConversation == null) return;

    final controller = TextEditingController(
      text: chatProvider.currentConversation!.title,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名对话'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入新标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                chatProvider.renameConversation(
                  chatProvider.currentConversation!.id,
                  newTitle,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}