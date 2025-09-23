import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/plaza_model.dart';
import '../services/customer_service.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = CustomerService();

  // Observable variables
  final RxList<PlazaModel> _plazas = <PlazaModel>[].obs;
  final RxList<ProductModel> _products = <ProductModel>[].obs;
  final RxList<ShopModel> _shops = <ShopModel>[].obs;
  final RxList<ProductModel> _favorites = <ProductModel>[].obs;
  final RxBool _isLoading = false.obs;
  final Rx<PlazaModel?> _selectedPlaza = Rx<PlazaModel?>(null);
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxDouble _minPrice = 0.0.obs;
  final RxDouble _maxPrice = 100000.0.obs;

  // Getters
  List<PlazaModel> get plazas => _plazas;
  List<ProductModel> get products => _filteredProducts;
  List<ShopModel> get shops => _shops;
  List<ProductModel> get favorites => _favorites;
  bool get isLoading => _isLoading.value;
  PlazaModel? get selectedPlaza => _selectedPlaza.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  double get minPrice => _minPrice.value;
  double get maxPrice => _maxPrice.value;

  List<String> get categories => [
    'All',
    'Mobile Phones',
    'Laptops',
    'Computers',
    'Accessories',
    'Tablets',
    'Gaming',
    'Audio',
    'Cameras',
  ];

  List<ProductModel> get _filteredProducts {
    var filtered = _products.where((product) {
      // Search filter
      if (_searchQuery.value.isNotEmpty) {
        if (!product.name.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            ) &&
            !product.description.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            )) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory.value != 'All' &&
          product.category != _selectedCategory.value) {
        return false;
      }

      // Price filter
      if (product.price < _minPrice.value || product.price > _maxPrice.value) {
        return false;
      }

      return true;
    }).toList();

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    loadPlazas();
  }

  Future<void> loadPlazas() async {
    try {
      _isLoading.value = true;
      final plazas = await _customerService.getPlazas();
      _plazas.assignAll(plazas);
    } catch (e) {
      _showError('Failed to load plazas: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> selectPlaza(PlazaModel plaza) async {
    _selectedPlaza.value = plaza;
    await loadShopsAndProducts();
  }

  Future<void> loadShopsAndProducts() async {
    if (_selectedPlaza.value == null) return;

    try {
      _isLoading.value = true;

      // Load shops in selected plaza
      final shops = await _customerService.getShopsByPlaza(
        _selectedPlaza.value!.id,
      );
      _shops.assignAll(shops);

      // Load products from these shops
      final products = await _customerService.getProductsByPlaza(
        _selectedPlaza.value!.id,
      );
      _products.assignAll(products);
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery.value = query;
  }

  void setCategory(String category) {
    _selectedCategory.value = category;
  }

  void setPriceRange(double min, double max) {
    _minPrice.value = min;
    _maxPrice.value = max;
  }

  Future<void> toggleFavorite(ProductModel product) async {
    try {
      final isFavorite = _favorites.any((fav) => fav.id == product.id);

      if (isFavorite) {
        _favorites.removeWhere((fav) => fav.id == product.id);
        await _customerService.removeFavorite(product.id);
      } else {
        _favorites.add(product);
        await _customerService.addFavorite(product.id);
      }
    } catch (e) {
      _showError('Failed to update favorites: $e');
    }
  }

  bool isFavorite(ProductModel product) {
    return _favorites.any((fav) => fav.id == product.id);
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await _customerService.getFavorites();
      _favorites.assignAll(favorites);
    } catch (e) {
      _showError('Failed to load favorites: $e');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
}
