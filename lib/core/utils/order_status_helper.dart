import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';

class OrderStatusHelper {
  OrderStatusHelper._();

  static const List<String> trackingSteps = <String>[
    'PENDING',
    'PAID',
    'SHIPPING',
    'DONE',
  ];

  static String label(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppStrings.orderStatusPending;
      case 'PAID':
        return AppStrings.orderStatusPaid;
      case 'SHIPPING':
        return AppStrings.orderStatusShipping;
      case 'DONE':
        return AppStrings.orderStatusDone;
      case 'CANCELLED':
        return AppStrings.orderStatusCancelled;
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'PAID':
        return const Color(0xFF8B5CF6);
      case 'SHIPPING':
        return const Color(0xFF3B82F6);
      case 'DONE':
        return const Color(0xFF22C55E);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  static int trackingStepIndex(String status) {
    final normalized = status.toUpperCase();
    if (normalized == 'CANCELLED') return -1;

    final index = trackingSteps.indexOf(normalized);
    return index < 0 ? 0 : index;
  }
}
