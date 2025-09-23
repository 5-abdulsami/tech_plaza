class ShopModel {
  final String id;
  final String ownerId;
  final String shopName;
  final String plazaId;
  final String address;
  final String description;
  final String? logoUrl;
  final String? phone;
  final ShopStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.shopName,
    required this.plazaId,
    required this.address,
    required this.description,
    this.logoUrl,
    this.phone,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      shopName: json['shop_name'] ?? '',
      plazaId: json['plaza_id'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logo_url'],
      phone: json['phone'],
      status: ShopStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ShopStatus.pending,
      ),
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
      'owner_id': ownerId,
      'shop_name': shopName,
      'plaza_id': plazaId,
      'address': address,
      'description': description,
      'logo_url': logoUrl,
      'phone': phone,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

enum ShopStatus { pending, active, suspended }

extension ShopStatusExtension on ShopStatus {
  String get displayName {
    switch (this) {
      case ShopStatus.pending:
        return 'Pending Approval';
      case ShopStatus.active:
        return 'Active';
      case ShopStatus.suspended:
        return 'Suspended';
    }
  }
}
