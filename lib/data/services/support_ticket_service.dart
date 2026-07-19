import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/api_config.dart';
import 'package:sales_online_app/data/models/support_ticket_model.dart';

class SupportTicketService {
  final Dio _dio;

  SupportTicketService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<SupportTicketModel>> fetchTicketsByUser(int userId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${ApiConfig.baseUrl}/support-requests',
        queryParameters: {'userId': userId},
      );

      final tickets = _parseTickets(response.data);
      return tickets.where((ticket) => ticket.userId == userId).toList();
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error, 'Không thể lấy lịch sử hỗ trợ.'));
    }
  }

  Future<void> submitTicket({
    required int userId,
    required String title,
    required String content,
  }) async {
    try {
      await _dio.post<dynamic>(
        '${ApiConfig.baseUrl}/support-requests',
        queryParameters: {'userId': userId},
        data: {'userId': userId, 'title': title, 'content': content},
      );
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error, 'Gửi yêu cầu hỗ trợ thất bại.'));
    }
  }

  List<SupportTicketModel> _parseTickets(dynamic data) {
    final source = data is List
        ? data
        : data is Map<String, dynamic> && data['content'] is List
        ? data['content'] as List
        : data is Map<String, dynamic> && data['data'] is List
        ? data['data'] as List
        : const <dynamic>[];

    return source
        .whereType<Map<String, dynamic>>()
        .map(SupportTicketModel.fromJson)
        .toList();
  }

  String _messageFromDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return fallback;
  }
}
