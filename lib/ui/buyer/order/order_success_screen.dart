import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/data/models/order_summary_model.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderSummaryModel summary;

  const OrderSuccessScreen({super.key, required this.summary});

  void _finishOrderFlow(BuildContext context) {
    Navigator.of(context).pop('order_success');
  }

  void _openOrderDetail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Màn hình chi tiết đơn hàng sẽ được bổ sung sau.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSpacing.h24,
                      Container(
                        width: 84,
                        height: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 52,
                        ),
                      ),
                      AppSpacing.h24,
                      Text(
                        'Đặt hàng thành công',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.h8,
                      Text(
                        'Đơn hàng của bạn đã được ghi nhận và đang chờ xử lý.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: mutedColor,
                          height: 1.45,
                        ),
                      ),
                      AppSpacing.h24,
                      _SummarySection(
                        surfaceColor: surfaceColor,
                        borderColor: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        children: [
                          _InfoRow(
                            label: 'Mã đơn hàng',
                            value: summary.orderId == null
                                ? 'Đang cập nhật'
                                : '#${summary.orderId}',
                          ),
                          _InfoRow(
                            label: 'Phương thức',
                            value: summary.paymentMethod,
                          ),
                          _InfoRow(
                            label: 'Tổng thanh toán',
                            value: _formatPrice(summary.totalAmount),
                            valueColor: AppColors.primary,
                          ),
                          _InfoRow(
                            label: 'Địa chỉ',
                            value: summary.address,
                            maxLines: 3,
                          ),
                        ],
                      ),
                      AppSpacing.h16,
                      _SummarySection(
                        surfaceColor: surfaceColor,
                        borderColor: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        title: 'Sản phẩm',
                        children: summary.items
                            .map((item) => _OrderItemTile(item: item))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _openOrderDetail(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.xLarge,
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Chi tiết đơn hàng'),
                        ),
                      ),
                      AppSpacing.h8,
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: () => _finishOrderFlow(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.xLarge,
                            ),
                          ),
                          child: const Text('Hoàn tất'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final Color surfaceColor;
  final Color borderColor;
  final String? title;
  final List<Widget> children;

  const _SummarySection({
    required this.surfaceColor,
    required this.borderColor,
    required this.children,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.large,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.headingMedium.copyWith(color: textColor),
            ),
            AppSpacing.h16,
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final int maxLines;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final CartItemModel item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.medium,
            child: SizedBox(
              width: 58,
              height: 58,
              child: item.product.imageUrl.isEmpty
                  ? const ColoredBox(
                      color: AppColors.borderLight,
                      child: Icon(Icons.image_not_supported_outlined),
                    )
                  : Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppColors.borderLight,
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  'x${item.quantity}',
                  style: AppTextStyles.caption.copyWith(color: mutedColor),
                ),
              ],
            ),
          ),
          AppSpacing.w8,
          Text(
            _formatPrice(item.totalPrice),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(double price) {
  final value = price.toStringAsFixed(0);
  final formatted = value.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '$formattedđ';
}
