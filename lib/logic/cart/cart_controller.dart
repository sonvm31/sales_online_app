import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/data/services/cart_service.dart';
import 'package:sales_online_app/data/services/shop_service.dart';

class CartController extends ChangeNotifier {
  final int? userId;
  final CartService _cartService;
  final ShopService _shopService;

  List<CartItemModel> _items = const <CartItemModel>[];
  final Set<int> _updatingItemIds = <int>{};
  bool _isLoading = false;
  bool _isClearing = false;
  String? _errorMessage;
  int? _ownedShopId;
  bool _hasResolvedOwnedShop = false;

  CartController({
    required this.userId,
    CartService? cartService,
    ShopService? shopService,
  }) : _cartService = cartService ?? CartService(),
       _shopService = shopService ?? ShopService();

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isClearing => _isClearing;
  String? get errorMessage => _errorMessage;
  bool get hasValidUser => userId != null && userId! > 0;
  bool isOwnShopProduct(int shopId) =>
      _ownedShopId != null && _ownedShopId == shopId;

  bool containsOwnShopProducts(Iterable<CartItemModel> items) {
    return items.any((item) => isOwnShopProduct(item.product.shop.id));
  }

  Future<void> loadOwnedShop({bool force = false}) async {
    if (!hasValidUser || (_hasResolvedOwnedShop && !force)) return;

    try {
      final shop = await _shopService.fetchShopByOwner(userId!);
      _ownedShopId = shop.id > 0 ? shop.id : null;
    } catch (_) {
      _ownedShopId = null;
    } finally {
      _hasResolvedOwnedShop = true;
      notifyListeners();
    }
  }

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  bool isUpdating(int cartItemId) {
    return _updatingItemIds.contains(cartItemId);
  }

  Future<void> loadCart({bool showLoading = true}) async {
    if (!hasValidUser) {
      _items = const <CartItemModel>[];
      _errorMessage = 'Không xác định được người dùng.';
      notifyListeners();
      return;
    }

    if (showLoading) {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _cartService.fetchCart(userId!);
    } catch (_) {
      _errorMessage = 'Không thể tải giỏ hàng.';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required int productId,
    int? productShopId,
    int quantity = 1,
  }) async {
    if (!hasValidUser) {
      throw CartException('Không xác định được người dùng.');
    }

    if (productShopId != null && isOwnShopProduct(productShopId)) {
      throw const CartException('Bạn không thể mua sản phẩm của shop mình.');
    }

    await _cartService.addToCart(
      userId: userId!,
      productId: productId,
      quantity: quantity,
    );
    await loadCart(showLoading: false);
  }

  Future<void> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    if (quantity < 1) {
      await removeItem(cartItemId);
      return;
    }

    _updatingItemIds.add(cartItemId);
    notifyListeners();

    try {
      await _cartService.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      await loadCart(showLoading: false);
    } finally {
      _updatingItemIds.remove(cartItemId);
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    _updatingItemIds.add(cartItemId);
    notifyListeners();

    try {
      await _cartService.removeItem(cartItemId);
      await loadCart(showLoading: false);
    } finally {
      _updatingItemIds.remove(cartItemId);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (!hasValidUser) {
      throw CartException('Không xác định được người dùng.');
    }

    _isClearing = true;
    notifyListeners();

    try {
      await _cartService.clearCart(userId!);
      await loadCart(showLoading: false);
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }
}

class CartException implements Exception {
  final String message;

  const CartException(this.message);

  @override
  String toString() => message;
}
