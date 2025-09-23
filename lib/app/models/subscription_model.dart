class SubscriptionModel {
  final String id;
  final String shopId;
  final SubscriptionPlan planType;
  final int listingLimit;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  SubscriptionModel({
    required this.id,
    required this.shopId,
    required this.planType,
    required this.listingLimit,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      shopId: json['shop_id'] ?? '',
      planType: SubscriptionPlan.values.firstWhere(
        (e) => e.toString().split('.').last == json['plan_type'],
        orElse: () => SubscriptionPlan.basic,
      ),
      listingLimit: json['listing_limit'] ?? 10,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'plan_type': planType.toString().split('.').last,
      'listing_limit': listingLimit,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

enum SubscriptionPlan { basic, standard, premium }

enum SubscriptionStatus { active, expired, suspended }

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.basic:
        return 'Basic Plan';
      case SubscriptionPlan.standard:
        return 'Standard Plan';
      case SubscriptionPlan.premium:
        return 'Premium Plan';
    }
  }

  int get listingLimit {
    switch (this) {
      case SubscriptionPlan.basic:
        return 10;
      case SubscriptionPlan.standard:
        return 30;
      case SubscriptionPlan.premium:
        return -1; // unlimited
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.basic:
        return 500.0;
      case SubscriptionPlan.standard:
        return 1500.0;
      case SubscriptionPlan.premium:
        return 3000.0;
    }
  }
}
