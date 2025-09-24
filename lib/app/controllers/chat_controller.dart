import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../services/chat_service.dart';
import '../controllers/auth_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxList<ChatModel> _chats = <ChatModel>[].obs;
  final RxList<MessageModel> _messages = <MessageModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isTyping = false.obs;
  final RxString _currentChatId = ''.obs;

  // Real-time subscription
  RealtimeChannel? _messagesSubscription;
  RealtimeChannel? _chatsSubscription;

  // Getters
  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isTyping => _isTyping.value;
  String get currentChatId => _currentChatId.value;

  @override
  void onInit() {
    super.onInit();
    loadChats();
    _setupRealtimeSubscriptions();
  }

  @override
  void onClose() {
    _messagesSubscription?.unsubscribe();
    _chatsSubscription?.unsubscribe();
    super.onClose();
  }

  void _setupRealtimeSubscriptions() {
    if (_authController.currentUser == null) return;

    final userId = _authController.currentUser!.id;

    // Subscribe to messages
    _messagesSubscription = Supabase.instance.client
        .channel('messages')
        // listen to inserts where current user is the sender
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sender_id',
            value: userId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            _handleNewMessage(message);
          },
        )
        // and also when current user is the receiver
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            _handleNewMessage(message);
          },
        )
        .subscribe();

    // Subscribe to chat updates
    _chatsSubscription = Supabase.instance.client
        .channel('chats')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chats',
          callback: (payload) {
            final chat = ChatModel.fromJson(payload.newRecord);
            _handleChatUpdate(chat);
          },
        )
        .subscribe();
  }

  void _handleNewMessage(MessageModel message) {
    // Add to current chat messages if viewing this chat
    if (_currentChatId.value.isNotEmpty) {
      final chat = _chats.firstWhereOrNull((c) => c.id == _currentChatId.value);
      if (chat != null &&
          (message.senderId == chat.customerId ||
              message.senderId == chat.shopOwnerId) &&
          (message.receiverId == chat.customerId ||
              message.receiverId == chat.shopOwnerId)) {
        _messages.add(message);
        _scrollToBottom();

        // Mark as read if user is receiver
        if (message.receiverId == _authController.currentUser!.id) {
          markMessageAsRead(message.id);
        }
      }
    }

    // Update chat list
    loadChats();
  }

  void _handleChatUpdate(ChatModel updatedChat) {
    final index = _chats.indexWhere((c) => c.id == updatedChat.id);
    if (index != -1) {
      _chats[index] = updatedChat;
    }
  }

  Future<void> loadChats() async {
    if (_authController.currentUser == null) return;

    try {
      _isLoading.value = true;
      final chats = await _chatService.getChats(
        _authController.currentUser!.id,
      );
      _chats.assignAll(chats);
    } catch (e) {
      _showError('Failed to load chats: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      _isLoading.value = true;
      _currentChatId.value = chatId;

      final messages = await _chatService.getMessages(chatId);
      _messages.assignAll(messages);

      // Mark messages as read
      await _markChatMessagesAsRead(chatId);

      _scrollToBottom();
    } catch (e) {
      _showError('Failed to load messages: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String> startChat({
    required String receiverId,
    required String shopId,
    String? productId,
  }) async {
    if (_authController.currentUser == null) return '';

    try {
      final chatId = await _chatService.createOrGetChat(
        customerId: _authController.isCustomer
            ? _authController.currentUser!.id
            : receiverId,
        shopOwnerId: _authController.isShopOwner
            ? _authController.currentUser!.id
            : receiverId,
        shopId: shopId,
        productId: productId,
      );

      return chatId;
    } catch (e) {
      _showError('Failed to start chat: $e');
      return '';
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String messageText,
    MessageType type = MessageType.text,
    String? productId,
  }) async {
    if (_authController.currentUser == null || messageText.trim().isEmpty)
      return;

    try {
      final message = MessageModel(
        id: '', // Will be generated by database
        senderId: _authController.currentUser!.id,
        receiverId: receiverId,
        messageText: messageText.trim(),
        type: type,
        timestamp: DateTime.now(),
        productId: productId,
      );

      await _chatService.sendMessage(chatId, message);

      // Message will be added via real-time subscription
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _chatService.markMessageAsRead(messageId);
    } catch (e) {
      // Silent fail for read receipts
    }
  }

  Future<void> _markChatMessagesAsRead(String chatId) async {
    if (_authController.currentUser == null) return;

    try {
      await _chatService.markChatMessagesAsRead(
        chatId,
        _authController.currentUser!.id,
      );

      // Update local chat unread count
      final chatIndex = _chats.indexWhere((c) => c.id == chatId);
      if (chatIndex != -1) {
        final updatedChat = ChatModel(
          id: _chats[chatIndex].id,
          customerId: _chats[chatIndex].customerId,
          shopOwnerId: _chats[chatIndex].shopOwnerId,
          shopId: _chats[chatIndex].shopId,
          productId: _chats[chatIndex].productId,
          lastMessage: _chats[chatIndex].lastMessage,
          unreadCount: 0,
          createdAt: _chats[chatIndex].createdAt,
          updatedAt: _chats[chatIndex].updatedAt,
        );
        _chats[chatIndex] = updatedChat;
      }
    } catch (e) {
      // Silent fail
    }
  }

  void setTyping(bool typing) {
    _isTyping.value = typing;
  }

  void clearCurrentChat() {
    _currentChatId.value = '';
    _messages.clear();
  }

  void _scrollToBottom() {
    // This would be called from the UI to scroll to bottom
    // Implementation depends on the ScrollController in the view
  }

  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  // Helper methods for UI
  String getChatTitle(ChatModel chat) {
    if (_authController.isCustomer) {
      // For customers, show shop name
      return 'Shop Chat'; // This would be populated with actual shop name
    } else {
      // For shop owners, show customer name
      return 'Customer Chat'; // This would be populated with actual customer name
    }
  }

  String getLastMessagePreview(ChatModel chat) {
    if (chat.lastMessage == null) return 'No messages yet';

    switch (chat.lastMessage!.type) {
      case MessageType.text:
        return chat.lastMessage!.messageText;
      case MessageType.image:
        return 'Image';
      case MessageType.product:
        return 'Product shared';
    }
  }

  bool isMessageFromCurrentUser(MessageModel message) {
    return message.senderId == _authController.currentUser?.id;
  }
}
