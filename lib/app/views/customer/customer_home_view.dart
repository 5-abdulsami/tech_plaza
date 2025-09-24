import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/product_card.dart';

class CustomerHomeView extends GetView<CustomerController> {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.selectedPlaza == null) {
          return _buildPlazaSelection();
        }
        return _buildHomeContent();
      }),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildPlazaSelection() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            Text(
              'select_plaza'.tr,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: controller.plazas.length,
                  itemBuilder: (context, index) {
                    final plaza = controller.plazas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary.withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_city,
                            color: Get.theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          plaza.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(plaza.address),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => controller.selectPlaza(plaza),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final authController = Get.find<AuthController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome'.tr,
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                Text(
                  authController.currentUser?.name ?? '',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.selectedPlaza != null)
                  Text(
                    controller.selectedPlaza!.name,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.searchProducts,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.tune),
            style: IconButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Get.theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory == category;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => controller.setCategory(category),
                backgroundColor: Get.theme.colorScheme.surface,
                selectedColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Get.theme.colorScheme.primary,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed(
              AppRoutes.productDetail,
              arguments: {'product': product},
            ),
            onFavorite: () => controller.toggleFavorite(product),
            isFavorite: controller.isFavorite(product),
          );
        },
      );
    });
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search_outlined),
          activeIcon: const Icon(Icons.search),
          label: 'search'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          activeIcon: const Icon(Icons.favorite),
          label: 'favorites'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_outlined),
          activeIcon: const Icon(Icons.chat),
          label: 'chat'.tr,
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
            // Already on home
            break;
          case 1:
            Get.toNamed(AppRoutes.search);
            break;
          case 2:
            Get.toNamed(AppRoutes.favorites);
            break;
          case 3:
            Get.toNamed(AppRoutes.chatList);
            break;
          case 4:
            Get.toNamed(AppRoutes.customerProfile);
            break;
        }
      },
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('filter'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price Range'),
            const SizedBox(height: 16),
            Obx(
              () => RangeSlider(
                values: RangeValues(controller.minPrice, controller.maxPrice),
                min: 0,
                max: 100000,
                divisions: 100,
                labels: RangeLabels(
                  'Rs. ${controller.minPrice.toInt()}',
                  'Rs. ${controller.maxPrice.toInt()}',
                ),
                onChanged: (values) {
                  controller.setPriceRange(values.start, values.end);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(onPressed: () => Get.back(), child: Text('apply'.tr)),
        ],
      ),
    );
  }
}
