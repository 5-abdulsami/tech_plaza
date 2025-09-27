import 'package:get/get.dart';
import '../bindings/chat_binding.dart';
import '../bindings/customer_binding.dart';
import '../views/customer/customer_profile_view.dart';
import '../views/customer/favorites_view.dart';
import '../views/customer/search_view.dart';
import '../views/shop/edit_product_view.dart';
import '../views/shop/payment_proof_view.dart';
import '../views/shop/product_list_view.dart';
import '../views/shop/shop_analytics_view.dart';
import '../views/shop/shop_profile_view.dart';
import 'app_routes.dart';

// Import all views
import '../views/splash/splash_view.dart';
import '../views/auth/role_selection_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/cnic_upload_view.dart';

// Customer views
import '../views/customer/customer_home_view.dart';
import '../views/customer/product_detail_view.dart';
import '../views/customer/customer_chat_view.dart';
import '../views/customer/chat_list_view.dart';

// Shop owner views
import '../views/shop/shop_dashboard_view.dart';
import '../views/shop/add_product_view.dart';

import '../views/settings/settings_view.dart';

// Import all bindings
import '../bindings/splash_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/shop_binding.dart';

class AppPages {
  static final routes = [
    // Auth Routes
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.cnicUpload,
      page: () => const CnicUploadView(),
      binding: AuthBinding(),
    ),

    // Customer Routes
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerChat,
      page: () => const CustomerChatView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerProfile,
      page: () => const CustomerProfileView(),
      binding: CustomerBinding(),
    ),

    // Shop Owner Routes
    GetPage(
      name: AppRoutes.shopDashboard,
      page: () => const ShopDashboardView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddProductView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => const EditProductView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),

    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentProof,
      page: () => const PaymentProofView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.shopAnalytics,
      page: () => const ShopAnalyticsView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.shopProfile,
      page: () => const ShopProfileView(),
      binding: ShopBinding(),
    ),

    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: AuthBinding(),
    ),
  ];
}
