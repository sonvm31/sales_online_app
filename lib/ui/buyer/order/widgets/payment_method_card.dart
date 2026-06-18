import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class PaymentMethodCard extends StatelessWidget {
  final bool isDark;
  final String selectedPaymentMethod;
  final Function(String method) onMethodChanged;

  const PaymentMethodCard({
    super.key,
    required this.isDark,
    required this.selectedPaymentMethod,
    required this.onMethodChanged,
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
            "Phương thức thanh toán:",
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textDark,
              fontSize: 16.0,
            ),
          ),
          AppSpacing.h8,
          RadioGroup<String>(
            groupValue: selectedPaymentMethod,
            onChanged: (v) {
              if (v != null) onMethodChanged(v);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(
                    "Thanh toán khi nhận hàng (COD)",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  value: "COD",
                  activeColor: AppColors.primary,
                ),
                RadioListTile<String>(
                  title: Text(
                    "Thanh toán qua ví VNPay",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  value: "VNPAY",
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
