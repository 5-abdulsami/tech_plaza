import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/user_model.dart';

class RoleSelectionView extends GetView<AuthController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'welcome'.tr,
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.onBackground,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'role_selection'.tr,
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    _buildRoleCard(
                      title: 'customer'.tr,
                      subtitle:
                          'Browse and discover electronics from local shops',
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => _navigateToAuth(UserRole.customer),
                    ),

                    const SizedBox(height: 24),

                    _buildRoleCard(
                      title: 'shop_owner'.tr,
                      subtitle: 'List your products and connect with customers',
                      icon: Icons.storefront_outlined,
                      onTap: () => _navigateToAuth(UserRole.shopOwner),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Language Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('language'.tr, style: Get.textTheme.bodyMedium),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'ur', label: Text('اردو')),
                    ],
                    selected: {Get.locale?.languageCode ?? 'en'},
                    onSelectionChanged: (Set<String> selection) {
                      Get.find<LanguageController>().changeLanguage(
                        selection.first,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Get.theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                title,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAuth(UserRole role) {
    Get.toNamed(AppRoutes.login, arguments: {'role': role});
  }
}
