import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/app_notification.dart';

class NotificationService {
  final Dio _dio;

  NotificationService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<List<AppNotification>> fetchAllNotifications() {
    return _fetch('/notifications');
  }

  Future<List<AppNotification>> fetchMobileNotifications({
    required String role,
  }) {
    return _fetch(
      '/notifications/mobile',
      queryParameters: {'role': _normalizeRole(role)},
    );
  }

  Future<List<AppNotification>> _fetch(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data ?? const <dynamic>[];
      return data
          .whereType<Map>()
          .map(
            (json) => AppNotification.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on DioException catch (error) {
      throw NotificationException(_messageFor(error));
    } on FormatException {
      throw const NotificationException('Dữ liệu thông báo không hợp lệ.');
    }
  }

  String _normalizeRole(String role) {
    final normalized = role.trim().toUpperCase();
    if (normalized == 'SELLER' || normalized == 'SELLERS') return 'SELLER';
    return 'BUYER';
  }

  String _messageFor(DioException error) {
    if (error.response?.statusCode != null) {
      return 'Không thể tải thông báo (${error.response!.statusCode}).';
    }
    return 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
  }
}

class NotificationException implements Exception {
  final String message;

  const NotificationException(this.message);

  @override
  String toString() => message;
}
