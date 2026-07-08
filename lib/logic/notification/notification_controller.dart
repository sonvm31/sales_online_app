import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/app_notification.dart';
import 'package:sales_online_app/data/services/notification_service.dart';
import 'package:sales_online_app/data/services/notification_storage_service.dart';

enum NotificationScope { all, mobile }

class NotificationController extends ChangeNotifier {
  final NotificationService _service;
  final NotificationStorageService _storageService;
  final NotificationScope scope;
  final String role;

  List<AppNotification> _notifications = const [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationController({
    this.role = 'BUYER',
    this.scope = NotificationScope.mobile,
    NotificationService? service,
    NotificationStorageService? storageService,
  }) : _service = service ?? NotificationService(),
       _storageService = storageService ?? NotificationStorageService();

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  Future<void> initialize() => loadNotifications();

  Future<void> loadNotifications() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = scope == NotificationScope.all
          ? await _service.fetchAllNotifications()
          : await _service.fetchMobileNotifications(role: role);
      final readIds = await _storageService.readIds();
      _notifications = results
          .map((item) => item.copyWith(isRead: readIds.contains(item.id)))
          .toList();
    } on NotificationException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Không thể tải thông báo. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere(
      (item) => item.id == notificationId,
    );
    if (index < 0 || _notifications[index].isRead) return;

    _notifications = [
      for (final item in _notifications)
        if (item.id == notificationId) item.copyWith(isRead: true) else item,
    ];
    notifyListeners();
    await _storageService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    _notifications = _notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();
    notifyListeners();
    await _storageService.markAllAsRead(_notifications.map((item) => item.id));
  }
}
