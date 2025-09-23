import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/plaza_model.dart';
import '../controllers/auth_controller.dart';
import 'package:get/get.dart';

class CustomerService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PlazaModel>> getPlazas() async {
    final response = await _client.from('plazas').select().order('name');

    return (response as List).map((json) => PlazaModel.fromJson(json)).toList();
  }

  Future<List<ShopModel>> getShopsByPlaza(String plazaId) async {
    final response = await _client
        .from('shops')
        .select()
        .eq('plaza_id', plazaId)
        .eq('status', 'active')
        .order('shop_name');

    return (response as List).map((json) => ShopModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getProductsByPlaza(String plazaId) async {
    final response = await _client
        .from('products')
        .select('''
          *,
          shops!inner(plaza_id)
        ''')
        .eq('shops.plaza_id', plazaId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>> searchProducts(
    String query,
    String? plazaId,
  ) async {
    var queryBuilder = _client
        .from('products')
        .select('''
          *,
          shops!inner(plaza_id)
        ''')
        .eq('is_active', true)
        .or('name.ilike.%$query%,description.ilike.%$query%');

    if (plazaId != null) {
      queryBuilder = queryBuilder.eq('shops.plaza_id', plazaId);
    }

    final response = await queryBuilder.order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final response = await _client
          .from('shops')
          .select()
          .eq('id', shopId)
          .single();

      return ShopModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> addFavorite(String productId) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;

    await _client.from('favorites').insert({
      'user_id': authController.currentUser!.id,
      'product_id': productId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String productId) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;

    await _client
        .from('favorites')
        .delete()
        .eq('user_id', authController.currentUser!.id)
        .eq('product_id', productId);
  }

  Future<List<ProductModel>> getFavorites() async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return [];

    final response = await _client
        .from('favorites')
        .select('''
          products(*)
        ''')
        .eq('user_id', authController.currentUser!.id);

    return (response as List)
        .map((json) => ProductModel.fromJson(json['products']))
        .toList();
  }
}
