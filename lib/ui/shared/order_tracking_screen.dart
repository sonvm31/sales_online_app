import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/services/order_service.dart';
import 'package:sales_online_app/logic/order_tracking/order_tracking_controller.dart';
import 'package:sales_online_app/ui/shared/order_tracking/order_tracking_role.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_info_card.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_map_card.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_status_card.dart';

export 'package:sales_online_app/ui/shared/order_tracking/order_tracking_role.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final OrderTrackingRole role;
  final OrderService? orderService;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.role,
    this.orderService,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final OrderTrackingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrderTrackingController(
      orderId: widget.orderId,
      orderService: widget.orderService,
    );
    _controller.loadOrder();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _screenTitle {
    return widget.role == OrderTrackingRole.seller
        ? AppStrings.orderTrackingSellerTitle
        : AppStrings.orderTrackingBuyerTitle;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final background = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return IconButton(
                onPressed: _controller.isLoading ? null : _controller.loadOrder,
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return _OrderTrackingBody(controller: _controller, role: widget.role);
        },
      ),
    );
  }
}

class _OrderTrackingBody extends StatelessWidget {
  final OrderTrackingController controller;
  final OrderTrackingRole role;

  const _OrderTrackingBody({required this.controller, required this.role});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (controller.errorMessage != null) {
      return _TrackingErrorState(
        message: controller.errorMessage!,
        onRetry: controller.loadOrder,
      );
    }

    final order = controller.order;
    if (order == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: controller.loadOrder,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          TrackingStatusCard(order: order, role: role),
          AppSpacing.h16,
          TrackingMapCard(
            order: order,
            routePoints: controller.routePoints,
            isRouteLoading: controller.isRouteLoading,
            shopLocation: controller.shopLocation,
            buyerLocation: controller.buyerLocation,
          ),
          AppSpacing.h16,
          TrackingInfoCard(order: order, role: role),
        ],
      ),
    );
  }
}

class _TrackingErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TrackingErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 58, color: mutedColor),
            AppSpacing.h16,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: textColor),
            ),
            AppSpacing.h16,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.orderTrackingRetry),
            ),
          ],
        ),
      ),
    );
  }
}
