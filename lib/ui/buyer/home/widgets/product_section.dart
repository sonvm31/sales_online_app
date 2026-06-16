import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/product_card.dart';
import 'package:sales_online_app/ui/buyer/product_detail/product_detail_screen.dart';

class ProductSection extends StatelessWidget {
  final bool isDark;
  final List<ProductModel> products;
  final bool isLoadingProducts;
  final bool isLoadingMore;
  final VoidCallback onRetry;

  const ProductSection({
    super.key,
    required this.isDark,
    required this.products,
    required this.isLoadingMore,
    required this.isLoadingProducts,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            "Gợi ý hôm nay",
            style: AppTextStyles.headingLarge.copyWith(
              color: isDark
                  ? AppColors.textMutedLight
                  : AppColors.textMutedDark,
            ),
          ),
        ),
        AppSpacing.h16,
        if (isLoadingProducts)
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (products.isEmpty && !isLoadingMore)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                "Hiện tại chưa có sản phẩm nào được đăng bán",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          )
        else ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
