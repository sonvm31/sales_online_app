import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class SellerHeader extends StatelessWidget {
  final String shopName;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const SellerHeader({
    super.key,
    required this.shopName,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 218,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.xl),
          bottomRight: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -74,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceLight.withValues(alpha: 0.7),
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                  AppSpacing.w24,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: [
                            Icon(
                              errorMessage == null
                                  ? Icons.circle
                                  : Icons.error_outline,
                              color: errorMessage == null
                                  ? const Color(0xFF65E46F)
                                  : Colors.orangeAccent,
                              size: 16,
                            ),
                            AppSpacing.w8,
                            Expanded(
                              child: Text(
                                isLoading
                                    ? 'Đang tải shop...'
                                    : errorMessage ?? 'Đã xác thực',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (errorMessage != null)
                              IconButton(
                                tooltip: 'Tải lại shop',
                                onPressed: onRetry,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: AppColors.textLight,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
