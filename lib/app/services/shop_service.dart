import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/subscription_model.dart';

class ShopService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ProductModel>> getProductsByShop(String shopId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _client
        .from('products')
        .insert(product.toJson())
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<void> updateProduct(ProductModel product) async {
    await _client
        .from('products')
        .update(product.toJson())
        .eq('id', product.id);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  Future<SubscriptionModel?> getSubscription(String shopId) async {
    try {
      final response = await _client
          .from('subscriptions')
          .select()
          .eq('shop_id', shopId)
          .eq('status', 'active')
          .single();

      return SubscriptionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getShopAnalytics(String shopId) async {
    // This would typically involve multiple queries or a stored procedure
    // For now, returning mock data
    return {'total_views': 150, 'total_chats': 25, 'total_orders': 8};
  }

  Future<String> uploadProductImage({
    required String imagePath,
    required String shopId,
  }) async {
    final file = File(imagePath);
    final fileExt = imagePath.split('.').last;
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final fullPath = '$shopId/$fileName';

    await _client.storage.from('product_images').upload(fullPath, file);

    return _client.storage.from('product_images').getPublicUrl(fullPath);
  }

  Future<String> uploadPaymentProof({
    required String imagePath,
    required String shopId,
  }) async {
    final file = File(imagePath);
    final fileExt = imagePath.split('.').last;
    final fileName =
        'payment_proof_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final fullPath = '$shopId/$fileName';

    await _client.storage.from('payment_proofs').upload(fullPath, file);

    return _client.storage.from('payment_proofs').getPublicUrl(fullPath);
  }

  Future<void> submitPaymentProof({
    required String shopId,
    required String proofImageUrl,
  }) async {
    await _client.from('payments').insert({
      'shop_id': shopId,
      'proof_image_url': proofImageUrl,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
