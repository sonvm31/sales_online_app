import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/support_ticket_model.dart';
import 'package:sales_online_app/data/services/support_ticket_service.dart';

class SupportTicketController extends ChangeNotifier {
  final int? userId;
  final SupportTicketService _service;

  List<SupportTicketModel> _tickets = <SupportTicketModel>[];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  SupportTicketController({required this.userId, SupportTicketService? service})
    : _service = service ?? SupportTicketService();

  List<SupportTicketModel> get tickets => List.unmodifiable(_tickets);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasValidUser => userId != null && userId! > 0;

  Future<void> loadTickets() async {
    final currentUserId = userId;
    if (currentUserId == null || currentUserId <= 0) {
      _tickets = <SupportTicketModel>[];
      _errorMessage = 'Không xác định được tài khoản đăng nhập.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await _service.fetchTicketsByUser(currentUserId);
    } catch (e) {
      _tickets = <SupportTicketModel>[];
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitTicket({
    required String title,
    required String content,
  }) async {
    final currentUserId = userId;
    if (currentUserId == null || currentUserId <= 0) {
      _errorMessage = 'Không xác định được tài khoản đăng nhập.';
      notifyListeners();
      return false;
    }

    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();
    if (normalizedTitle.isEmpty || normalizedContent.isEmpty) {
      _errorMessage = 'Vui lòng điền đầy đủ thông tin yêu cầu!';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.submitTicket(
        userId: currentUserId,
        title: normalizedTitle,
        content: normalizedContent,
      );
      await loadTickets();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
