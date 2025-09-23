import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Authentication methods
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User profile methods
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    await _client.from('users').insert(user.toJson());
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _client.from('users').update(user.toJson()).eq('id', user.id);
  }

  // Shop methods
  Future<ShopModel?> getShopByOwnerId(String ownerId) async {
    try {
      final response = await _client
          .from('shops')
          .select()
          .eq('owner_id', ownerId)
          .single();

      return ShopModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<ShopModel> createShop(ShopModel shop) async {
    final response = await _client
        .from('shops')
        .insert(shop.toJson())
        .select()
        .single();

    return ShopModel.fromJson(response);
  }

  Future<void> updateShop(ShopModel shop) async {
    await _client.from('shops').update(shop.toJson()).eq('id', shop.id);
  }

  // File upload methods
  Future<String> uploadImage({
    required String filePath,
    required String bucket,
    required String fileName,
  }) async {
    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fullFileName =
        '$fileName.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage.from(bucket).upload(fullFileName, file);

    return _client.storage.from(bucket).getPublicUrl(fullFileName);
  }

  Future<void> deleteImage({
    required String bucket,
    required String fileName,
  }) async {
    await _client.storage.from(bucket).remove([fileName]);
  }
}
