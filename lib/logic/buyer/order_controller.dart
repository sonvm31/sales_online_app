import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
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

  bool isLoading = false;
  String? errMessage;
  int? lastCreatedOrderId;

  OrderController({required this.orderItems, this.authController}) {
    _initDynamicUserData();
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

  void updateLocationInfo({
    required String address,
    required double lat,
    required double lng,
  }) {
    selectedAddress = address;
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }

  Future<String?> processPlaceOrder() async {
    if (isLoading) return null;
    if (userId == null) {
      errMessage = "Không tìm thấy phiên đăng nhập. Vui lòng thử lại!";
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
      };

      final response = await _orderService.createOrder(requestBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData != null) {
          if(responseData is Map){

          lastCreatedOrderId = int.tryParse(responseData['id'].toString());
          } else if(responseData is String){
            try {
              final Map<String, dynamic> parsedJson = jsonDecode(responseData);
              lastCreatedOrderId = int.tryParse(parsedJson['id'].toString());
            } catch (_) {
              final match = RegExp(r'"id"\s*:\s*(\d+)').firstMatch(responseData);
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
        if(lastCreatedOrderId == null || lastCreatedOrderId == 0){
          throw Exception("Không thể trích xuất ID đơn hàng từ phản hồi của Backend.");
        }
        if (selectedPaymentMethod == "VNPAY") {
          final vnpayUrl = await _orderService.createPaymentUrl(
            orderId: lastCreatedOrderId!,
            amount: totalProductPrice,
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
}
