import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_plaza/app/models/subscription_model.dart';
import '../../controllers/shop_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/shop_model.dart';

class ShopDashboardView extends GetView<ShopController> {
  const ShopDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (authController.currentShop?.status == ShopStatus.pending) {
            return _buildPendingApprovalView();
          }

          if (authController.currentShop?.status == ShopStatus.suspended) {
            return _buildSuspendedView();
          }

          return _buildDashboardContent();
        }),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: Obx(() {
        if (authController.currentShop?.status != ShopStatus.active) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.addProduct),
          child: const Icon(Icons.add),
        );
      }),
    );
  }

  Widget _buildPendingApprovalView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.pending_outlined,
                size: 50,
                color: Get.theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Shop Pending Approval',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Your shop registration is under review. Admin will verify your CNIC and approve your shop shortly.',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => Get.find<AuthController>().refreshUserData(),
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspendedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.block,
                size: 50,
                color: Get.theme.colorScheme.error,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Shop Suspended',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Your shop has been suspended. Please contact support for more information.',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: controller.loadShopData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildSubscriptionCard(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authController = Get.find<AuthController>();
    final shop = authController.currentShop;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard'.tr,
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (shop != null)
                Text(
                  shop.shopName,
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.shopSettings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Products',
              value: controller.activeProducts.toString(),
              icon: Icons.inventory_2_outlined,
              color: Get.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Views',
              value: controller.totalViews.toString(),
              icon: Icons.visibility_outlined,
              color: Get.theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Chats',
              value: controller.totalChats.toString(),
              icon: Icons.chat_outlined,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Obx(() {
      final subscription = controller.subscription;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_membership,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'subscription'.tr,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.paymentProof),
                    child: const Text('Upgrade'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (subscription != null) ...[
                Text(
                  subscription.planType.displayName,
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Listings: ${controller.activeProducts}/${subscription.listingLimit == -1 ? "Unlimited" : subscription.listingLimit}',
                  style: Get.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: subscription.listingLimit == -1
                      ? 0.1
                      : controller.activeProducts / subscription.listingLimit,
                  backgroundColor: Get.theme.colorScheme.surfaceVariant,
                ),
              ] else ...[
                Text(
                  'No active subscription',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'add_product'.tr,
                icon: Icons.add_box_outlined,
                onTap: () => Get.toNamed(AppRoutes.addProduct),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'my_products'.tr,
                icon: Icons.inventory_outlined,
                onTap: () => Get.toNamed(AppRoutes.productList),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'analytics'.tr,
                icon: Icons.analytics_outlined,
                onTap: () => Get.toNamed(AppRoutes.shopAnalytics),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'shop_profile'.tr,
                icon: Icons.store_outlined,
                onTap: () => Get.toNamed(AppRoutes.shopProfile),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Get.theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProducts() {
    return Obx(() {
      final recentProducts = controller.products.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Products',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.productList),
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (recentProducts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No products yet',
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.addProduct),
                        child: Text('add_product'.tr),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...recentProducts.map(
              (product) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image),
                  ),
                  title: Text(product.name),
                  subtitle: Text('Rs. ${product.price.toStringAsFixed(0)}'),
                  trailing: Switch(
                    value: product.isActive,
                    onChanged: (_) =>
                        controller.toggleProductStatus(product.id),
                  ),
                  onTap: () => Get.toNamed(
                    AppRoutes.editProduct,
                    arguments: {'product': product},
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: 'dashboard'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_outlined),
          activeIcon: const Icon(Icons.inventory),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_outlined),
          activeIcon: const Icon(Icons.chat),
          label: 'chat'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics_outlined),
          activeIcon: const Icon(Icons.analytics),
          label: 'analytics'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'profile'.tr,
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Get.toNamed(AppRoutes.productList);
            break;
          case 2:
            Get.toNamed(AppRoutes.shopChat);
            break;
          case 3:
            Get.toNamed(AppRoutes.shopAnalytics);
            break;
          case 4:
            Get.toNamed(AppRoutes.shopProfile);
            break;
        }
      },
    );
  }
}
