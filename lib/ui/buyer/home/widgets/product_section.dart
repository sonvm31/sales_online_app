import 'package:flutter/cupertino.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/product_card.dart';

class ProductSection extends StatelessWidget {
  final bool isDark;
  final List<Map<String, String>> products;

  const ProductSection({required this.isDark, required this.products});

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
            style: AppTextStyles.headingLarge.copyWith(color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark),
          ),
        ),
        AppSpacing.h16,
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
            itemBuilder: (context, index){
              return ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}
