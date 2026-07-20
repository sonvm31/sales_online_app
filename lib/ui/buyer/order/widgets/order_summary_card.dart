import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/core/utils/currency_formatter.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';

class OrderSummaryCard extends StatelessWidget {
  final bool isDark;
  final List<CartItemModel> orderItems;
  final double totalProductPrice;
  final double shippingFee;
  final bool isCalculatingShipping;
  final String? shippingErrorMessage;

  const OrderSummaryCard({
    super.key,
    required this.isDark,
    required this.orderItems,
    required this.totalProductPrice,
    required this.shippingFee,
    required this.isCalculatingShipping,
    this.shippingErrorMessage,
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
                    CurrencyFormatter.vnd(item.totalPrice),
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.vnd(totalProductPrice),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                  "Phí vận chuyển:",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
              ),
              isCalculatingShipping
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : shippingErrorMessage != null
                  ? Text(
                      "Không thể tính",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      CurrencyFormatter.vnd(shippingFee),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          if (shippingErrorMessage != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              shippingErrorMessage!,
              style: AppTextStyles.caption.copyWith(color: Colors.orange),
            ),
          ],
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
                  "Tổng thanh toán:",
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                    fontSize: 16.0.sp,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.vnd(totalProductPrice + shippingFee),
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
