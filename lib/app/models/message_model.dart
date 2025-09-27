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
