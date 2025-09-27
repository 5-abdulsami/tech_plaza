import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    // Ensure AuthController is fully initialized
    if (!_authController.isInitialized) {
      await _authController.initializeAuth();
    }

    // Now safely check authentication
    if (_authController.isAuthenticated &&
        _authController.currentUser != null) {
      _navigateBasedOnRole();
    } else {
      Get.offAllNamed(AppRoutes.roleSelection);
    }
    debugPrint(
      "SplashController: isAuthenticated=${_authController.isAuthenticated}, user=${_authController.currentUser}",
    );
  }

  void _navigateBasedOnRole() {
    final user = _authController.currentUser;

    if (user == null) {
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

    switch (user.role) {
      case UserRole.customer:
        Get.offAllNamed(AppRoutes.customerHome);
        break;
      case UserRole.shopOwner:
        Get.offAllNamed(AppRoutes.shopDashboard);
        break;
      case UserRole.admin:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
