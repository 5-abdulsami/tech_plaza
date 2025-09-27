import 'message_model.dart';

class ChatModel {
  final String id;
  final String customerId;
  final String shopOwnerId;
  final String shopId;
  final String? productId;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.customerId,
    required this.shopOwnerId,
    required this.shopId,
    this.productId,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      shopOwnerId: json['shop_owner_id'] ?? '',
      shopId: json['shop_id'] ?? '',
      productId: json['product_id'],
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'shop_owner_id': shopOwnerId,
      'shop_id': shopId,
      'product_id': productId,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
