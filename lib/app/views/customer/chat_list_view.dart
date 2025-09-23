import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import '../../routes/app_routes.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadChats,
        child: Obx(() {
          if (controller.isLoading && controller.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_outlined,
                    size: 64,
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: Get.theme.colorScheme.onBackground.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with shop owners',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.onBackground.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.chats.length,
            itemBuilder: (context, index) {
              final chat = controller.chats[index];
              return _buildChatTile(chat);
            },
          );
        }),
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(Icons.storefront, color: Get.theme.colorScheme.primary),
        ),

        title: Text(
          controller.getChatTitle(chat),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          controller.getLastMessagePreview(chat),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastMessage != null)
              Text(
                _formatTime(chat.lastMessage!.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),

            if (chat.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: TextStyle(
                    color: Get.theme.colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        onTap: () =>
            Get.toNamed(AppRoutes.customerChat, arguments: {'chat': chat}),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
