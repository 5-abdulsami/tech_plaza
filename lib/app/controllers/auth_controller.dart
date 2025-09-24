import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final Rx<ShopModel?> _currentShop = Rx<ShopModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;

  // Add an RxBool to signal when the controller's initialization is complete
  final RxBool _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  // Getters
  UserModel? get currentUser => _currentUser.value;
  ShopModel? get currentShop => _currentShop.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isShopOwner => currentUser?.role == UserRole.shopOwner;
  bool get isCustomer => currentUser?.role == UserRole.customer;

  @override
  void onInit() {
    super.onInit();
    // _initializeAuth();
  }

  Future<void> initializeAuth() async {
    try {
      _isLoading.value = true;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        await _loadUserData(session.user.id);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading.value = false;
      _isInitialized.value = true; // Signal that initialization is complete
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final userData = await _authService.getUserById(userId);
      if (userData != null) {
        _currentUser.value = userData;
        _isAuthenticated.value = true;

        // Load shop data if user is shop owner
        if (userData.role == UserRole.shopOwner) {
          final shopData = await _authService.getShopByOwnerId(userId);
          _currentShop.value = shopData;
        }
      }
    } catch (e) {
      debugPrint('Load user data error: $e');
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading.value = true;

      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
        _navigateBasedOnRole();
        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar(
        'login_error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? cnic,
  }) async {
    try {
      _isLoading.value = true;

      // Validate CNIC for shop owners
      if (role == UserRole.shopOwner && (cnic == null || cnic.isEmpty)) {
        Get.snackbar(
          'error'.tr,
          'cnic_required'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        final user = UserModel(
          id: response.user!.id,
          name: name,
          email: email,
          phone: phone,
          role: role,
          cnic: cnic,
          createdAt: DateTime.now(),
        );

        await _authService.createUserProfile(user);
        _currentUser.value = user;
        _isAuthenticated.value = true;

        // Navigate to CNIC upload if shop owner
        if (role == UserRole.shopOwner) {
          Get.toNamed(AppRoutes.cnicUpload);
        } else {
          _navigateBasedOnRole();
        }

        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar(
        'registration_error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> uploadCnicAndCreateShop({
    required String cnicImagePath,
    required String shopName,
    required String plazaId,
    required String address,
    required String description,
    String? phone,
    String? logoPath,
  }) async {
    try {
      _isLoading.value = true;

      if (currentUser == null) return false;

      // Upload CNIC image
      final cnicUrl = await _authService.uploadImage(
        filePath: cnicImagePath,
        bucket: 'cnic_images',
        fileName: '${currentUser!.id}_cnic',
      );

      // Upload logo if provided
      String? logoUrl;
      if (logoPath != null) {
        logoUrl = await _authService.uploadImage(
          filePath: logoPath,
          bucket: 'shop_logos',
          fileName: '${currentUser!.id}_logo',
        );
      }

      // Create shop
      final shop = ShopModel(
        id: '', // Will be generated by database
        ownerId: currentUser!.id,
        shopName: shopName,
        plazaId: plazaId,
        address: address,
        description: description,
        logoUrl: logoUrl,
        phone: phone,
        status: ShopStatus.pending,
        createdAt: DateTime.now(),
      );

      final createdShop = await _authService.createShop(shop);
      _currentShop.value = createdShop;

      // Update user with CNIC URL
      final updatedUser = currentUser!.copyWith(cnic: cnicUrl);
      await _authService.updateUserProfile(updatedUser);
      _currentUser.value = updatedUser;

      _navigateBasedOnRole();
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      await _authService.signOut();

      // Clear user data
      _currentUser.value = null;
      _currentShop.value = null;
      _isAuthenticated.value = false;

      // Clear stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userKey);
      await prefs.remove(AppConstants.tokenKey);

      // Navigate to role selection
      Get.offAllNamed(AppRoutes.roleSelection);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _navigateBasedOnRole() {
    if (currentUser == null) return;

    switch (currentUser!.role) {
      case UserRole.customer:
        Get.offAllNamed(AppRoutes.customerHome);
        break;
      case UserRole.shopOwner:
        if (currentShop?.status == ShopStatus.pending) {
          Get.snackbar(
            'info'.tr,
            'shop_pending_approval'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        }
        Get.offAllNamed(AppRoutes.shopDashboard);
        break;
    }
  }

  Future<void> refreshUserData() async {
    if (currentUser != null) {
      await _loadUserData(currentUser!.id);
    }
  }
}
