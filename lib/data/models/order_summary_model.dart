import 'package:sales_online_app/data/models/cart_item_model.dart';

class OrderSummaryModel {
  final int? orderId;
  final List<CartItemModel> items;
  final String address;
  final String paymentMethod;
  final double totalAmount;

  const OrderSummaryModel({
    required this.orderId,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
  });
}
