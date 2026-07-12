import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/core/utils/order_status_helper.dart';

class TrackingStatusChip extends StatelessWidget {
  final String status;

  const TrackingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = OrderStatusHelper.color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        OrderStatusHelper.label(status),
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
