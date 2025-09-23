class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String messageText;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? productId;
  final String? shopId;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.productId,
    this.shopId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      messageText: json['message_text'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] ?? false,
      productId: json['product_id'],
      shopId: json['shop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_text': messageText,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'product_id': productId,
      'shop_id': shopId,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? messageText,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? productId,
    String? shopId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageText: messageText ?? this.messageText,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      productId: productId ?? this.productId,
      shopId: shopId ?? this.shopId,
    );
  }
}

enum MessageType { text, image, product }

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
