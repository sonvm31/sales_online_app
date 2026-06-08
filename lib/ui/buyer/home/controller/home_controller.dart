import 'package:flutter/cupertino.dart';
import 'package:sales_online_app/data/models/category_model.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/services/category_service.dart';
import 'package:sales_online_app/data/services/product_service.dart';

class HomeController extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  late Future<List<CategoryModel>> categoriesFuture;
  int selectedCategoryIndex = 0;

  final ScrollController scrollController = ScrollController();
  final List<ProductModel> products = [];
  int _currPage = 0;
  bool isLoadingProducts = false;
  bool isLoadingMore = false;
  bool _hasMoreProducts = true;

  HomeController() {
    scrollController.addListener(_onScroll);
  }

  void loadAllData() {
    loadCategories();
    fetchInitProducts();
  }

  void loadCategories() {
    categoriesFuture = _categoryService.fetchCategories();
    notifyListeners();
  }

  void changeCategoryIndex(int index) {
    selectedCategoryIndex = index;
    notifyListeners();
  }

  Future<void> fetchInitProducts() async {
    if (isLoadingProducts) return;

    isLoadingProducts = true;
    _currPage = 0;
    _hasMoreProducts = true;
    products.clear();
    notifyListeners();

    try {
      final result = await _productService.fetchProducts(page: _currPage);
      final List<ProductModel> newProducts = result['products'];

      newProducts.shuffle();

      products.addAll(newProducts);
      isLoadingProducts = false;
      _hasMoreProducts = !result['isLast'];
    } catch (e) {
      isLoadingProducts = false;
    }
    notifyListeners();
  }

  Future<void> fetchMoreProducts() async {
    if (isLoadingMore || !_hasMoreProducts) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      _currPage++;
      final result = await _productService.fetchProducts(page: _currPage);
      final List<ProductModel> nextProducts = result['products'];
      nextProducts.shuffle();

      products.addAll(nextProducts);
      isLoadingMore = false;
      _hasMoreProducts = !result['isLast'];
    } catch (e) {
      isLoadingMore = false;
    }
    notifyListeners();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currScroll = scrollController.position.pixels;

    if (maxScroll - currScroll <= 100) {
      fetchMoreProducts();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}
