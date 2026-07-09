import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/data/services/order_service.dart';

class BuyerOrdersController extends ChangeNotifier {
  final int? userId;
  final String? statusFilter;
  final OrderService _orderService;

  List<OrderModel> _orders = const <OrderModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  BuyerOrdersController({
    required this.userId,
    this.statusFilter,
    OrderService? orderService,
  }) : _orderService = orderService ?? OrderService();

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    final currentUserId = userId;
    if (currentUserId == null || currentUserId <= 0) {
      _orders = const <OrderModel>[];
      _errorMessage = 'Không xác định được người dùng.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedOrders = await _orderService.fetchOrdersByUser(currentUserId);
      final normalizedFilter = statusFilter?.toUpperCase();
      _orders = normalizedFilter == null
          ? loadedOrders
          : loadedOrders
                .where(
                  (order) => order.status.toUpperCase() == normalizedFilter,
                )
                .toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
