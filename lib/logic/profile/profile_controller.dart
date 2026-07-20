import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/models/seller_revenue_model.dart';
import 'package:sales_online_app/data/services/shop_service.dart';
import 'package:sales_online_app/data/services/seller_revenue_service.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';

class ProfileController extends ChangeNotifier {
  final AuthController authController;
  final ShopService _shopService;
  final SellerRevenueService _revenueService;

  late bool _isSellerMode;
  ShopModel? _sellerShop;
  bool _isLoadingShop = false;
  String? _shopErrorMessage;
  bool _isRegisteringShop = false;
  SellerRevenueModel? _sellerRevenue;
  bool _isLoadingRevenue = false;
  String? _revenueErrorMessage;

  ProfileController({
    required this.authController,
    ShopService? shopService,
    SellerRevenueService? revenueService,
  }) : _shopService = shopService ?? ShopService(),
       _revenueService = revenueService ?? SellerRevenueService() {
    // A role alone is not enough to open the seller UI: the shop can still be
    // waiting for approval or be locked. Start in Buyer until its status loads.
    _isSellerMode = false;
    loadSellerShop();
  }

  bool get isSellerMode => _isSellerMode;
  ShopModel? get sellerShop => _sellerShop;
  bool get hasSellerShop => _sellerShop != null && _sellerShop!.id > 0;
  bool get isSellerAccount =>
      authController.session?.role.toUpperCase() == 'SELLER';
  bool get isLoadingShop => _isLoadingShop;
  bool get isRegisteringShop => _isRegisteringShop;
  String? get shopErrorMessage => _shopErrorMessage;
  int get shopId => _sellerShop?.id ?? 0;
  bool get isSellerShopActive => _sellerShop?.isActive == true;
  double get totalRevenue => _sellerRevenue?.totalRevenue ?? 0;
  bool get isLoadingRevenue => _isLoadingRevenue;
  String? get revenueErrorMessage => _revenueErrorMessage;
  ShopRegistrationState get shopRegistrationState {
    if (!hasSellerShop) return ShopRegistrationState.notRegistered;
    if (isSellerShopActive) return ShopRegistrationState.active;
    if (isSellerAccount) return ShopRegistrationState.locked;
    return ShopRegistrationState.pending;
  }

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

  Future<SellerApprovalStatus> checkSellerApproval() async {
    await loadSellerShop();

    if (_sellerShop == null || _sellerShop!.id <= 0) {
      return SellerApprovalStatus.notFound;
    }

    if (_sellerShop!.isActive) {
      _isSellerMode = true;
      notifyListeners();
      return SellerApprovalStatus.active;
    }

    _isSellerMode = false;
    notifyListeners();
    return SellerApprovalStatus.inactive;
  }

  Future<void> registerShop({
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required String avatarUrl,
  }) async {
    final userId = authController.session?.userId;
    if (userId == null || userId <= 0) {
      throw Exception('Không xác định được tài khoản đăng ký shop.');
    }

    _isRegisteringShop = true;
    notifyListeners();

    try {
      await _shopService.registerShop(
        userId: userId,
        name: name,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        avatarUrl: avatarUrl,
      );
    } finally {
      _isRegisteringShop = false;
      notifyListeners();
    }
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
      _isSellerMode = _sellerShop!.isActive && isSellerAccount;
      if (_isSellerMode && _sellerShop!.id > 0) {
        await loadRevenue(shopId: _sellerShop!.id);
      }
    } catch (e) {
      _sellerShop = null;
      _isSellerMode = false;
      _shopErrorMessage = e.toString().replaceFirst('Exception: ', '');
      _sellerRevenue = null;
    } finally {
      _isLoadingShop = false;
      notifyListeners();
    }
  }

  Future<void> loadRevenue({int? shopId}) async {
    final id = shopId ?? _sellerShop?.id;
    if (id == null || id <= 0) {
      _sellerRevenue = null;
      _revenueErrorMessage = 'Không tìm thấy shop để tải doanh thu.';
      notifyListeners();
      return;
    }

    _isLoadingRevenue = true;
    _revenueErrorMessage = null;
    notifyListeners();

    try {
      _sellerRevenue = await _revenueService.fetchRevenue(id);
    } catch (e) {
      _revenueErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingRevenue = false;
      notifyListeners();
    }
  }
}

enum SellerApprovalStatus { active, inactive, notFound }

enum ShopRegistrationState { notRegistered, pending, active, locked }
