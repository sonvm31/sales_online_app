import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';

class OrderSummaryCard extends StatelessWidget {
  final bool isDark;
  final List<CartItemModel> orderItems;
  final double totalProductPrice;

  const OrderSummaryCard({
    super.key,
    required this.isDark,
    required this.orderItems,
    required this.totalProductPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.large,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sản phẩm đã chọn:",
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textDark,
              fontSize: 16.0.sp,
            ),
          ),
          Divider(
            height: AppSpacing.md,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          ...orderItems.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${item.quantity}x ${item.product.name}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    "${item.totalPrice.toStringAsFixed(0)}đ",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: AppSpacing.md,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Tổng tiền hàng:",
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                    fontSize: 16.0.sp,
                  ),
                ),
              ),
              Text(
                "${totalProductPrice.toStringAsFixed(0)}đ",
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
