import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';

class CustomerChatView extends GetView<ChatController> {
  const CustomerChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final chat = arguments['chat'] as ChatModel?;
    final shop = arguments['shop'] as ShopModel?;
    final product = arguments['product'] as ProductModel?;

    final messageController = TextEditingController();
    final scrollController = ScrollController();

    // Load messages if chat exists, otherwise start new chat
    if (chat != null) {
      controller.loadMessages(chat.id);
    } else if (shop != null) {
      _startNewChat(shop, product);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shop?.shopName ?? controller.getChatTitle(chat!),
              style: const TextStyle(fontSize: 16),
            ),
            if (product != null)
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 12,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Column(
        children: [
          // Product card if chatting about specific product
          if (product != null) _buildProductCard(product),

          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(message);
                },
              );
            }),
          ),

          // Message input
          _buildMessageInput(messageController, chat, shop),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rs. ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Get.theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isFromCurrentUser = controller.isMessageFromCurrentUser(message);

    return Align(
      alignment: isFromCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isFromCurrentUser
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isFromCurrentUser ? const Radius.circular(4) : null,
            bottomLeft: !isFromCurrentUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.messageText,
              style: TextStyle(
                color: isFromCurrentUser
                    ? Get.theme.colorScheme.onPrimary
                    : Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isFromCurrentUser
                        ? Get.theme.colorScheme.onPrimary.withOpacity(0.7)
                        : Get.theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.7,
                          ),
                  ),
                ),

                if (isFromCurrentUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: Get.theme.colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    TextEditingController messageController,
    ChatModel? chat,
    ShopModel? shop,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Get.theme.colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _sendMessage(messageController, chat, shop),
                icon: Icon(Icons.send, color: Get.theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startNewChat(ShopModel shop, ProductModel? product) async {
    final chatId = await controller.startChat(
      receiverId: shop.ownerId,
      shopId: shop.id,
      productId: product?.id,
    );

    if (chatId.isNotEmpty) {
      controller.loadMessages(chatId);
    }
  }

  void _sendMessage(
    TextEditingController messageController,
    ChatModel? chat,
    ShopModel? shop,
  ) async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    messageController.clear();

    String chatId = chat?.id ?? controller.currentChatId;
    String receiverId = chat?.shopOwnerId ?? shop!.ownerId;

    // If no chat exists, create one first
    if (chatId.isEmpty && shop != null) {
      chatId = await controller.startChat(
        receiverId: shop.ownerId,
        shopId: shop.id,
      );
    }

    if (chatId.isNotEmpty) {
      await controller.sendMessage(
        chatId: chatId,
        receiverId: receiverId,
        messageText: messageText,
      );
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
