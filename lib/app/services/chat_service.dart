import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ChatModel>> getChats(String userId) async {
    final response = await _client
        .from('chats')
        .select('''
          *,
          last_message:messages!chats_last_message_id_fkey(*),
          shops(shop_name),
          users!chats_customer_id_fkey(name),
          shop_owners:users!chats_shop_owner_id_fkey(name)
        ''')
        .or('customer_id.eq.$userId,shop_owner_id.eq.$userId')
        .order('updated_at', ascending: false);

    return (response as List).map((json) => ChatModel.fromJson(json)).toList();
  }

  Future<List<MessageModel>> getMessages(String chatId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('timestamp', ascending: true);

    return (response as List)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }

  Future<String> createOrGetChat({
    required String customerId,
    required String shopOwnerId,
    required String shopId,
    String? productId,
  }) async {
    // Check if chat already exists
    try {
      final existingChat = await _client
          .from('chats')
          .select('id')
          .eq('customer_id', customerId)
          .eq('shop_owner_id', shopOwnerId)
          .eq('shop_id', shopId)
          .maybeSingle();

      if (existingChat != null) {
        return existingChat['id'];
      }
    } catch (e) {
      // Chat doesn't exist, create new one
    }

    // Create new chat
    final response = await _client
        .from('chats')
        .insert({
          'customer_id': customerId,
          'shop_owner_id': shopOwnerId,
          'shop_id': shopId,
          'product_id': productId,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'];
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    // Insert message
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': message.senderId,
      'receiver_id': message.receiverId,
      'message_text': message.messageText,
      'type': message.type.toString().split('.').last,
      'timestamp': message.timestamp.toIso8601String(),
      'product_id': message.productId,
    });

    // Update chat's last message and timestamp
    await _client
        .from('chats')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', chatId);
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }

  Future<void> markChatMessagesAsRead(String chatId, String userId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('messages')
        .select('id')
        .eq('receiver_id', userId)
        .eq('is_read', false);

    // response is a List<dynamic> in latest SDK
    final list = (response as List);
    return list.length;
  }
}
