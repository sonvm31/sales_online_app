import 'package:flutter/cupertino.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/services/product_service.dart';

class SearchResultController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final String keyword;

  final List<ProductModel> products = [];
  final ScrollController scrollController = ScrollController();

  int _currPage = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errMessage;

  String _sortBy = 'id';
  String _sortDirection = 'asc';
  double? _minPrice;
  double? _maxPrice;

  SearchResultController({required this.keyword}) {
    scrollController.addListener(_onScroll);
    fetchInitSearchResult();
  }

  String get currSortType => "${_sortBy}_${_sortDirection.toUpperCase()}";

  Future<void> fetchInitSearchResult() async {
    if (isLoading) return;

    isLoading = true;
    _currPage = 0;
    hasMore = true;
    products.clear();
    errMessage = null;
    notifyListeners();

    try {
      final result = await _productService.searchProducts(
        keyword: keyword,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        page: _currPage,
        size: 10,
      );

      final List<ProductModel> newProducts = result['products'];
      products.addAll(newProducts);
      hasMore = !result['isLast'];
    } catch (e) {
      errMessage = "Không thể tải kết quả tìm kiếm. Vui lòng thử lại!";
      debugPrint("Lỗi gọi API Search nâng cao: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchMoreSearchResults() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      _currPage++;
      final result = await _productService.searchProducts(
        keyword: keyword,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        page: _currPage,
        size: 10,
      );

      final List<ProductModel> nextProducts = result['products'];
      products.addAll(nextProducts);
      hasMore = !result['isLast'];
    } catch (e) {
      debugPrint("Lỗi Lazy Load trang $_currPage: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void updateSort(String sortType){
    if(sortType == "PRICE_ASC"){
      _sortBy = "price";
      _sortDirection = "asc";
    } else if (sortType == 'PRICE_DESC'){
      _sortBy = 'price';
      _sortDirection = 'desc';
    } else {
      _sortBy = 'id';
      _sortDirection = 'asc';
    }
    fetchInitSearchResult();
  }

  void updatePriceFilter(double? min, double? max){
    _minPrice = min;
    _maxPrice = max;
    fetchInitSearchResult();
  }

  void _onScroll(){
    if(!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currScroll = scrollController.position.pixels;

    if(maxScroll - currScroll <= 100){
      _fetchMoreSearchResults();
    }
  }

  @override
  void dispose(){
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}
