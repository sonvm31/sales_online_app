import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/core/utils/currency_formatter.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/ui/shared/widgets/app_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedPrice = CurrencyFormatter.vnd(product.price);

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: AppRadius.xLarge,
      elevation: isDark ? 4 : 1,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(AppSpacing.sm),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: AppRadius.large),
                child: AppImage(
                  imageData: product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  backgroundColor: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  errorWidget: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    formattedPrice,
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
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      AppSpacing.w4,
                      Expanded(
                        child: Text(
                          product.shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
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
    );
  }
}
