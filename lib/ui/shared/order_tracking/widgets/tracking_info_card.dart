import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/core/utils/order_status_helper.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/ui/shared/order_tracking/order_tracking_role.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_card.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_info_row.dart';

class TrackingInfoCard extends StatelessWidget {
  final OrderModel order;
  final OrderTrackingRole role;

  const TrackingInfoCard({super.key, required this.order, required this.role});

  @override
  Widget build(BuildContext context) {
    final shop = order.orderItems.isEmpty
        ? null
        : order.orderItems.first.product.shop;

    return TrackingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackingInfoRow(
            label: AppStrings.orderTrackingStatus,
            value: OrderStatusHelper.label(order.status),
          ),
          TrackingInfoRow(
            label: AppStrings.orderTrackingPayment,
            value: order.paymentMethod,
          ),
          TrackingInfoRow(
            label: role == OrderTrackingRole.seller
                ? AppStrings.orderTrackingCustomer
                : AppStrings.orderTrackingShop,
            value: role == OrderTrackingRole.seller
                ? _customerName(order)
                : shop?.name ?? AppStrings.orderTrackingUnknownShop,
          ),
          TrackingInfoRow(
            label: AppStrings.orderTrackingDeliveryAddress,
            value: order.address,
            maxLines: 3,
          ),
          TrackingInfoRow(
            label: AppStrings.orderTrackingTotal,
            value: '${order.totalAmount.toStringAsFixed(0)}đ',
          ),
        ],
      ),
    );
  }

  String _customerName(OrderModel order) {
    if (order.user.fullName.isNotEmpty) return order.user.fullName;
    if (order.user.email.isNotEmpty) return order.user.email;
    return '${AppStrings.orderTrackingCustomer} #${order.user.id}';
  }
}
