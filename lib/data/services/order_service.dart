import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';

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
    required String paymentMethod
  }) async {
    try {
      final response = await _dio.post(
        '/payment/create-payment-url',
        queryParameters: {'orderId': orderId, 'amount': amount, 'paymentMethod': paymentMethod},
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

  Future<double> calculateShippingFee({
    required double shopLat,
    required double shopLng,
    required double userLat,
    required double userLng,
  }) async {
    try {
      final response = await _dio.get(
        '/shipping/calculate',
        queryParameters: {
          'shopLat': shopLat,
          'shopLng': shopLng,
          'userLat': userLat,
          'userLng': userLng,
        },
      );
      if (response.statusCode == 200) {
        return double.tryParse(response.data.toString()) ?? 0.0;
      }
      throw Exception('Không thể tính phí ship từ máy chủ.');
    } on DioException catch (e) {
      final errMessage = e.response?.data?['message'] ?? "Lỗi kết nối Server!";
      throw Exception(errMessage);
    } catch (e) {
      throw Exception("Đã xảy ra lỗi ngoài dự kiến khi tính phí ship.");
    }
  }
}
