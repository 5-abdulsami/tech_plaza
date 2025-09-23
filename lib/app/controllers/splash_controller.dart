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

    // Check authentication status
    if (_authController.isAuthenticated) {
      _navigateBasedOnRole();
    } else {
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  void _navigateBasedOnRole() {
    if (_authController.currentUser == null) {
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

    switch (_authController.currentUser!.role) {
      case UserRole.customer:
        Get.offAllNamed(AppRoutes.customerHome);
        break;
      case UserRole.shopOwner:
        Get.offAllNamed(AppRoutes.shopDashboard);
        break;
    }
  }
}
