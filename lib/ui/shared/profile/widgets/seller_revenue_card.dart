import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class SellerRevenueCard extends StatelessWidget {
  final double totalRevenue;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const SellerRevenueCard({
    super.key,
    required this.totalRevenue,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: AppRadius.xLarge,
      child: InkWell(
        onTap: errorMessage == null ? null : onRetry,
        borderRadius: AppRadius.xLarge,
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.xLarge,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: Color(0x26FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
              ),
              AppSpacing.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sellerTotalRevenue,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    AppSpacing.h4,
                    if (isLoading)
                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else if (errorMessage != null)
                      Text(
                        'Không thể tải — chạm để thử lại',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        '${totalRevenue.toStringAsFixed(0)}đ',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (!isLoading && errorMessage == null) ...[
                      AppSpacing.h4,
                      Text(
                        AppStrings.sellerRevenueDescription,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (errorMessage != null)
                const Icon(Icons.refresh, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
