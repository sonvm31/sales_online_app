import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/data/models/order_summary_model.dart';
import 'package:sales_online_app/data/services/order_service.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';

class OrderController extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final List<CartItemModel> orderItems;
  final AuthController? authController;

  int? userId;
  String selectedAddress = "Chưa chọn địa chỉ";
  String selectedPaymentMethod = "COD";

  double latitude = 10.841200;
  double longitude = 106.809900;

  double shippingFee = 0.0;
  bool isCalculatingShipping = false;
  String? shippingErrorMessage;

  bool isLoading = false;
  String? errMessage;
  int? lastCreatedOrderId;

  double? get shopLatitude =>
      orderItems.isNotEmpty ? orderItems.first.product.shop.latitude : null;

  double? get shopLongitude =>
      orderItems.isNotEmpty ? orderItems.first.product.shop.longitude : null;
  OrderController({required this.orderItems, this.authController}) {
    _initDynamicUserData();
    fetchShippingFee();
  }

  void _initDynamicUserData() {
    if (authController != null && authController!.session != null) {
      userId = authController!.session!.userId;
      debugPrint("Đã bốc thành công User ID số từ AuthSession: $userId");
    }
  }

  double get totalProductPrice {
    return orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void setPaymentMethod(String method) {
    if (selectedPaymentMethod == method) return;
    selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<void> fetchShippingFee() async {
    if (orderItems.isEmpty) return;
    isCalculatingShipping = true;
    shippingErrorMessage = null;
    notifyListeners();
    try {
      double? shopLat = shopLatitude;
      double? shopLng = shopLongitude;

      final shopAddress = orderItems.first.product.shop.address;
      if (shopAddress != null && shopAddress.trim().isNotEmpty) {
        try {
          final dio = Dio();
          final response = await dio.get(
            'https://nominatim.openstreetmap.org/search',
            queryParameters: {
              'q': shopAddress,
              'format': 'json',
              'limit': 1,
              'accept-language': 'vi',
              'countrycodes': 'vn',
            },
            options: Options(
              headers: {
                'User-Agent': 'SalesOnlineApp/1.0 (fuongduy@gmail.com)',
              },
            ),
          );
          if (response.statusCode == 200 &&
              response.data is List &&
              (response.data as List).isNotEmpty) {
            final first = (response.data as List).first;
            shopLat = double.tryParse(first['lat'].toString()) ?? shopLat;
            shopLng = double.tryParse(first['lon'].toString()) ?? shopLng;
            debugPrint("Quy đổi địa chỉ shop thành công: $shopLat, $shopLng");
          }
        } catch (e) {
          debugPrint("Lỗi quy đổi địa chỉ shop: $e");
        }
      }

      if (!_hasValidLocation(shopLat, shopLng)) {
        shippingFee = 0.0;
        shippingErrorMessage =
            'Shop chưa có địa chỉ hoặc tọa độ để tính phí vận chuyển.';
        return;
      }

      final fee = await _orderService.calculateShippingFee(
        shopLat: shopLat!,
        shopLng: shopLng!,
        userLat: latitude,
        userLng: longitude,
      );
      shippingFee = fee;
    } catch (e) {
      debugPrint("Lỗi tính phí vận chuyển: $e");
      shippingFee = 0.0;
      shippingErrorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isCalculatingShipping = false;
      notifyListeners();
    }
  }

  void updateLocationInfo({
    required String address,
    required double lat,
    required double lng,
  }) {
    selectedAddress = address;
    latitude = lat;
    longitude = lng;
    notifyListeners();
    fetchShippingFee();
  }

  Future<String?> processPlaceOrder() async {
    if (isLoading) return null;
    if (userId == null) {
      errMessage = "Không tìm thấy phiên đăng nhập. Vui lòng thử lại!";
      notifyListeners();
      return null;
    }

    if (shippingErrorMessage != null) {
      errMessage = shippingErrorMessage;
      notifyListeners();
      return null;
    }

    isLoading = true;
    errMessage = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> itemsPayload = orderItems.map((item) {
        return {'productId': item.product.id, 'quantity': item.quantity};
      }).toList();

      final Map<String, dynamic> requestBody = {
        'userId': userId,
        'items': itemsPayload,
        'address': selectedAddress,
        'paymentMethod': selectedPaymentMethod,
        'latitude': latitude,
        'longitude': longitude,
        'shippingFee': shippingFee,
      };

      final response = await _orderService.createOrder(requestBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData != null) {
          if (responseData is Map) {
            lastCreatedOrderId = int.tryParse(responseData['id'].toString());
          } else if (responseData is String) {
            try {
              final Map<String, dynamic> parsedJson = jsonDecode(responseData);
              lastCreatedOrderId = int.tryParse(parsedJson['id'].toString());
            } catch (_) {
              final match = RegExp(
                r'"id"\s*:\s*(\d+)',
              ).firstMatch(responseData);
              if (match != null) {
                lastCreatedOrderId = int.tryParse(match.group(1) ?? "");
              }
            }
          }
        } else {
          throw Exception(
            "Backend tạo đơn thành công nhưng không trả về ID đơn hàng hợp lệ.",
          );
        }
        if (lastCreatedOrderId == null || lastCreatedOrderId == 0) {
          throw Exception(
            "Không thể trích xuất ID đơn hàng từ phản hồi của Backend.",
          );
        }
        if (selectedPaymentMethod == "VNPAY") {
          final vnpayUrl = await _orderService.createPaymentUrl(
            orderId: lastCreatedOrderId!,
            amount: totalProductPrice + shippingFee,
            paymentMethod: selectedPaymentMethod,
          );
          isLoading = false;
          notifyListeners();
          return vnpayUrl;
        }

        isLoading = false;
        notifyListeners();
        return "";
      }
      throw Exception('Mã phản hồi không hợp lệ: ${response.statusCode}');
    } catch (e) {
      isLoading = false;
      errMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return null;
    }
  }

  OrderSummaryModel buildOrderSummary() {
    return OrderSummaryModel(
      orderId: lastCreatedOrderId,
      items: orderItems,
      address: selectedAddress,
      paymentMethod: selectedPaymentMethod,
      productAmount: totalProductPrice,
      shippingFee: shippingFee,
      totalAmount: totalProductPrice + shippingFee,
    );
  }

  bool _hasValidLocation(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }
}
