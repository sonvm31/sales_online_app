import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class ProductCard extends StatelessWidget {
  final Map<String, String> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.xLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: AppRadius.large,
                image: DecorationImage(
                  image: NetworkImage(product['image']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.md - 2,
                right: AppSpacing.md - 2,
                bottom: AppSpacing.md - 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                AppSpacing.h8,
                Text(
                  product['price']!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.h8,
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 14,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight
                    ),
                    AppSpacing.w4,
                    Expanded(
                        child: Text(
                          product['store']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        )
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
