import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/data/services/cart_service.dart';

class CartController extends ChangeNotifier {
  final int? userId;
  final CartService _cartService;

  List<CartItemModel> _items = const <CartItemModel>[];
  final Set<int> _updatingItemIds = <int>{};
  bool _isLoading = false;
  bool _isClearing = false;
  String? _errorMessage;

  CartController({required this.userId, CartService? cartService})
    : _cartService = cartService ?? CartService();

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isClearing => _isClearing;
  String? get errorMessage => _errorMessage;
  bool get hasValidUser => userId != null && userId! > 0;

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  bool isUpdating(int cartItemId) {
    return _updatingItemIds.contains(cartItemId);
  }

  Future<void> loadCart() async {
    if (!hasValidUser) {
      _items = const <CartItemModel>[];
      _errorMessage = 'Không xác định được người dùng.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _cartService.fetchCart(userId!);
    } catch (_) {
      _errorMessage = 'Không thể tải giỏ hàng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({required int productId, int quantity = 1}) async {
    if (!hasValidUser) {
      throw CartException('Không xác định được người dùng.');
    }

    await _cartService.addToCart(
      userId: userId!,
      productId: productId,
      quantity: quantity,
    );
    await loadCart();
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
      await loadCart();
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
      await loadCart();
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
      await loadCart();
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
