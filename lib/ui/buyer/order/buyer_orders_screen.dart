import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/core/utils/currency_formatter.dart';
import 'package:sales_online_app/core/utils/order_status_helper.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/logic/buyer/buyer_orders_controller.dart';
import 'package:sales_online_app/ui/shared/order_tracking_screen.dart';

class BuyerOrdersScreen extends StatefulWidget {
  final int? userId;
  final String title;
  final String? statusFilter;

  const BuyerOrdersScreen({
    super.key,
    required this.userId,
    required this.title,
    this.statusFilter,
  });

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  late final BuyerOrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BuyerOrdersController(
      userId: widget.userId,
      statusFilter: widget.statusFilter,
    );
    _controller.loadOrders();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openTracking(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackingScreen(
          orderId: order.id,
          role: OrderTrackingRole.buyer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : _controller.loadOrders,
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return _BuyerOrdersBody(
            controller: _controller,
            onOpenTracking: _openTracking,
          );
        },
      ),
    );
  }
}

class _BuyerOrdersBody extends StatelessWidget {
  final BuyerOrdersController controller;
  final ValueChanged<OrderModel> onOpenTracking;

  const _BuyerOrdersBody({
    required this.controller,
    required this.onOpenTracking,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (controller.errorMessage != null) {
      return _BuyerOrdersMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải đơn mua',
        message: controller.errorMessage!,
        actionLabel: 'Thử lại',
        onAction: controller.loadOrders,
      );
    }

    if (controller.orders.isEmpty) {
      return _BuyerOrdersMessage(
        icon: Icons.receipt_long_outlined,
        title: 'Chưa có đơn mua',
        message: 'Bạn chưa có đơn hàng nào trong trạng thái này.',
        actionLabel: 'Tải lại',
        onAction: controller.loadOrders,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadOrders,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.md),
        itemBuilder: (context, index) {
          final order = controller.orders[index];
          return _BuyerOrderCard(
            order: order,
            textColor: textColor,
            mutedColor: mutedColor,
            isDark: isDark,
            onTap: () => onOpenTracking(order),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: controller.orders.length,
      ),
    );
  }
}

class _BuyerOrderCard extends StatelessWidget {
  final OrderModel order;
  final Color textColor;
  final Color mutedColor;
  final bool isDark;
  final VoidCallback onTap;

  const _BuyerOrderCard({
    required this.order,
    required this.textColor,
    required this.mutedColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = OrderStatusHelper.color(order.status);
    final shopName = order.orderItems.isEmpty
        ? 'Chưa rõ shop'
        : order.orderItems.first.product.shop.name;

    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: AppRadius.large,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.large,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.large,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đơn #${order.id}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      OrderStatusHelper.label(order.status),
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h8,
              Text(
                shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.h4,
              Text(
                order.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${order.orderItems.length} sản phẩm',
                    style: AppTextStyles.caption.copyWith(color: mutedColor),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.vnd(order.totalAmount),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyerOrdersMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _BuyerOrdersMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 58, color: mutedColor),
        AppSpacing.h16,
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headingMedium.copyWith(color: textColor),
        ),
        AppSpacing.h8,
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
        ),
        AppSpacing.h16,
        Center(
          child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ),
      ],
    );
  }
}
