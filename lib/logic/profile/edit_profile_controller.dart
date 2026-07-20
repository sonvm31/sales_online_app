import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/models/update_profile_request.dart';
import 'package:sales_online_app/data/services/user_profile_service.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';

class EditProfileController extends ChangeNotifier {
  final AuthController _authController;
  final ShopModel? _shop;
  final UserProfileService _service;

  bool _isSaving = false;
  String? _errorMessage;

  EditProfileController({
    required AuthController authController,
    required ShopModel? shop,
    UserProfileService? service,
  }) : _authController = authController,
       _shop = shop,
       _service = service ?? UserProfileService();

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> save({
    required String fullName,
    required String phone,
    required String shopName,
    required String shopDescription,
    required String shopAvatarUrl,
    String? selectedShopAddress,
    double? selectedLatitude,
    double? selectedLongitude,
    String? selectedDeliveryAddress,
    double? selectedDeliveryLatitude,
    double? selectedDeliveryLongitude,
  }) async {
    final userId = _authController.session?.userId;
    if (userId == null || userId <= 0) {
      _errorMessage = 'Không xác định được tài khoản đăng nhập.';
      notifyListeners();
      return false;
    }

    final request = UpdateProfileRequest(
      fullName: _changedValue(fullName, _authController.session?.fullName),
      phone: _changedValue(phone, _authController.session?.phone),
      address: selectedDeliveryAddress,
      shopName: _changedValue(shopName, _shop?.name),
      shopDescription: _changedValue(shopDescription, _shop?.description),
      shopAvatarUrl: _changedValue(shopAvatarUrl, _shop?.avatarUrl),
      shopAddress: selectedShopAddress,
      latitude: selectedLatitude,
      longitude: selectedLongitude,
    );

    if (!request.hasChanges) {
      _errorMessage = 'Bạn chưa thay đổi thông tin nào.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateProfile(userId: userId, request: request);
      await _authController.updateSessionProfile(
        fullName: request.fullName,
        phone: request.phone,
        address: selectedDeliveryAddress,
        deliveryLatitude: selectedDeliveryLatitude,
        deliveryLongitude: selectedDeliveryLongitude,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String? _changedValue(String value, String? originalValue) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty ||
        normalizedValue == (originalValue ?? '').trim()) {
      return null;
    }
    return normalizedValue;
  }
}
