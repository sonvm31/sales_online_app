import 'package:flutter/foundation.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/data/services/order_service.dart';

class BuyerOrdersController extends ChangeNotifier {
  final int? userId;
  final String? statusFilter;
  final OrderService _orderService;

  List<OrderModel> _orders = const <OrderModel>[];
  bool _isLoading = false;
  int? _confirmingOrderId;
  String? _errorMessage;

  BuyerOrdersController({
    required this.userId,
    this.statusFilter,
    OrderService? orderService,
  }) : _orderService = orderService ?? OrderService();

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isConfirmingReceipt(int orderId) => _confirmingOrderId == orderId;

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

  Future<bool> confirmOrderReceived(OrderModel order) async {
    if (order.status.toUpperCase() != 'SHIPPING') {
      _errorMessage = 'Chỉ có thể xác nhận khi đơn hàng đang giao.';
      notifyListeners();
      return false;
    }

    _confirmingOrderId = order.id;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _orderService.confirmOrderReceived(orderId: order.id);
      final normalizedFilter = statusFilter?.toUpperCase();
      if (normalizedFilter == 'SHIPPING') {
        _orders = _orders.where((item) => item.id != order.id).toList();
      } else {
        _orders = [
          for (final item in _orders) if (item.id == order.id) updated else item,
        ];
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _confirmingOrderId = null;
      notifyListeners();
    }
  }
}
