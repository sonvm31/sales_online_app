import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/core/utils/order_status_helper.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/ui/shared/order_tracking/order_tracking_role.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_card.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_status_chip.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_timeline_step.dart';

class TrackingStatusCard extends StatelessWidget {
  final OrderModel order;
  final OrderTrackingRole role;

  const TrackingStatusCard({
    super.key,
    required this.order,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final cancelled = order.status.toUpperCase() == 'CANCELLED';
    final currentStep = OrderStatusHelper.trackingStepIndex(order.status);
    final subtitle = cancelled
        ? AppStrings.orderTrackingCancelledMessage
        : role == OrderTrackingRole.seller
        ? AppStrings.orderTrackingSellerSubtitle
        : AppStrings.orderTrackingBuyerSubtitle;

    return TrackingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đơn #${order.id}',
            style: AppTextStyles.headingMedium.copyWith(color: textColor),
          ),
          AppSpacing.h8,
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
          ),
          AppSpacing.h16,
          if (cancelled)
            TrackingStatusChip(status: order.status)
          else
            Column(
              children: [
                for (var i = 0; i < OrderStatusHelper.trackingSteps.length; i++)
                  TrackingTimelineStep(
                    title: OrderStatusHelper.label(
                      OrderStatusHelper.trackingSteps[i],
                    ),
                    isDone: i <= currentStep,
                    isLast: i == OrderStatusHelper.trackingSteps.length - 1,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
