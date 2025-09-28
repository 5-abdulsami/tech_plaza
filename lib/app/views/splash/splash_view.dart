import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // final SplashController _controller = Get.find<SplashController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
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
      case UserRole.shop_owner:
        Get.offAllNamed(AppRoutes.shopDashboard);
        break;
      case UserRole.admin:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 60,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            Text(
              'app_name'.tr,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Local Electronics Marketplace',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
