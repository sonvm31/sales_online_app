import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/data/services/order_route_service.dart';
import 'package:sales_online_app/data/services/order_service.dart';

class OrderTrackingController extends ChangeNotifier {
  final int orderId;
  final OrderService _orderService;
  final OrderRouteService _routeService;

  OrderModel? _order;
  List<LatLng> _routePoints = const <LatLng>[];
  LatLng? _shopLocation;
  LatLng? _buyerLocation;
  bool _isLoading = true;
  bool _isRouteLoading = false;
  String? _errorMessage;

  OrderTrackingController({
    required this.orderId,
    OrderService? orderService,
    OrderRouteService? routeService,
  }) : _orderService = orderService ?? OrderService(),
       _routeService = routeService ?? OrderRouteService();

  OrderModel? get order => _order;
  List<LatLng> get routePoints => _routePoints;
  LatLng? get shopLocation => _shopLocation;
  LatLng? get buyerLocation => _buyerLocation;
  bool get isLoading => _isLoading;
  bool get isRouteLoading => _isRouteLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrder() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedOrder = await _orderService.fetchOrderDetail(orderId);
      _order = loadedOrder;
      _shopLocation = _resolveShopLocation(loadedOrder);
      _buyerLocation = _resolveBuyerLocation(loadedOrder);
      notifyListeners();
      await _loadRoute();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRoute() async {
    final shop = _shopLocation;
    final buyer = _buyerLocation;

    if (shop == null || buyer == null) {
      _routePoints = const <LatLng>[];
      notifyListeners();
      return;
    }

    _isRouteLoading = true;
    notifyListeners();

    try {
      _routePoints = await _routeService.fetchRoute(
        shopLocation: shop,
        buyerLocation: buyer,
      );
    } finally {
      _isRouteLoading = false;
      notifyListeners();
    }
  }

  LatLng? _resolveBuyerLocation(OrderModel order) {
    if (!_hasValidLocation(order.latitude, order.longitude)) return null;
    return LatLng(order.latitude, order.longitude);
  }

  LatLng? _resolveShopLocation(OrderModel order) {
    if (order.orderItems.isEmpty) return null;

    final shop = order.orderItems.first.product.shop;
    final lat = shop.latitude;
    final lng = shop.longitude;
    if (lat == null || lng == null || !_hasValidLocation(lat, lng)) {
      return null;
    }

    return LatLng(lat, lng);
  }

  bool _hasValidLocation(double lat, double lng) {
    return lat.isFinite &&
        lng.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }
}
