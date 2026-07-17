import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/services/shop_service.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';

class ProfileController extends ChangeNotifier {
  final AuthController authController;
  final ShopService _shopService;

  late bool _isSellerMode;
  ShopModel? _sellerShop;
  bool _isLoadingShop = false;
  String? _shopErrorMessage;

  ProfileController({required this.authController, ShopService? shopService})
    : _shopService = shopService ?? ShopService() {
    _isSellerMode = authController.session?.role.toUpperCase() == 'SELLER';
    if (_isSellerMode) {
      loadSellerShop();
    }
  }

  bool get isSellerMode => _isSellerMode;
  ShopModel? get sellerShop => _sellerShop;
  bool get isLoadingShop => _isLoadingShop;
  String? get shopErrorMessage => _shopErrorMessage;
  int get shopId => _sellerShop?.id ?? 0;

  String get displayName {
    final user = FirebaseAuth.instance.currentUser;
    return authController.session?.fullName?.trim().isNotEmpty == true
        ? authController.session!.fullName!.trim()
        : user?.displayName ?? user?.email ?? 'Người dùng';
  }

  String get shopName {
    final name = _sellerShop?.name.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Shop của tôi';
  }

  void switchToBuyer() {
    if (!_isSellerMode) return;
    _isSellerMode = false;
    notifyListeners();
  }

  void switchToSeller() {
    if (_isSellerMode) return;
    _isSellerMode = true;
    notifyListeners();
    loadSellerShop();
  }

  Future<void> loadSellerShop() async {
    final userId = authController.session?.userId;
    if (userId == null || userId <= 0) {
      _sellerShop = null;
      _shopErrorMessage = 'Không xác định được người bán.';
      notifyListeners();
      return;
    }

    _isLoadingShop = true;
    _shopErrorMessage = null;
    notifyListeners();

    try {
      _sellerShop = await _shopService.fetchShopByOwner(userId);
    } catch (e) {
      _shopErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingShop = false;
      notifyListeners();
    }
  }
}
