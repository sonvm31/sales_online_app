import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/order_model.dart';

class OrderService {
  final Dio _dio = DioClient().dio;

  Future<Response> createOrder(Map<String, dynamic> orderPayload) async {
    try {
      final response = await _dio.post('/orders', data: orderPayload);
      return response;
    } on DioException catch (e) {
      final errMessage = e.response?.data?['message'] ?? "Lỗi kết nối Server!";
      throw Exception(errMessage);
    } catch (e) {
      throw Exception("Đã xảy ra lỗi ngoài dự kiến khi đặt hàng.");
    }
  }

  Future<String> createPaymentUrl({
    required int orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post(
        '/payment/create-payment-url',
        queryParameters: {
          'orderId': orderId,
          'amount': amount,
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String vnpayUrl = response.data.toString().trim();

        return vnpayUrl;
      }
      throw Exception("Không thể khởi tạo link VNPay.");
    } catch (e) {
      throw Exception("Lỗi gọi API VNPay từ hệ thống.");
    }
  }

  Future<List<OrderModel>> fetchOrdersByShop(int shopId) async {
    try {
      final response = await _dio.get('/orders/shop/$shopId');

      if (response.statusCode == 200) {
        return _parseOrders(response.data);
      }

      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể lấy danh sách đơn hàng: $e');
    }
  }

  Future<OrderModel> fetchOrderDetail(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          return OrderModel.fromJson(Map<String, dynamic>.from(data));
        }
      }

      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể lấy chi tiết đơn hàng: $e');
    }
  }

  Future<OrderModel> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final response = await _dio.put('/orders/$orderId/$status');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          return OrderModel.fromJson(Map<String, dynamic>.from(data));
        }
        return fetchOrderDetail(orderId);
      }

      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  List<OrderModel> _parseOrders(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final rawItems = data['data'] ?? data['content'] ?? data['orders'];
      if (rawItems is List) {
        return rawItems
            .whereType<Map>()
            .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    }

    return <OrderModel>[];
  }
}
