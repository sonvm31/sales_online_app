import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/product_card.dart';
import 'package:sales_online_app/ui/buyer/product_detail/product_detail_screen.dart';

class SearchResultGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoadingMore;
  final CartController? cartController;

  const SearchResultGrid({
    super.key,
    required this.products,
    required this.isLoadingMore,
    this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
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
                      builder: (_) => ProductDetailScreen(
                        productId: product.id,
                        cartController: cartController,
                      ),
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
    );
  }
}
