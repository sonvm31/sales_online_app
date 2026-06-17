import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/services/product_service.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final CartController? cartController;
  final ProductService? productService;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.cartController,
    this.productService,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductService _productService;
  late Future<ProductModel> _productFuture;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _productService = widget.productService ?? ProductService();
    _loadProduct();
  }

  void _loadProduct() {
    _productFuture = _productService.fetchProductDetail(widget.productId);
  }

  void _retry() {
    setState(_loadProduct);
  }

  Future<void> _addToCart(ProductModel product) async {
    final cartController = widget.cartController;
    if (cartController == null || !cartController.hasValidUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không xác định được người dùng.')),
      );
      return;
    }

    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm hiện đã hết hàng.')),
      );
      return;
    }

    setState(() => _isAddingToCart = true);
    try {
      await cartController.addToCart(productId: product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thêm vào giỏ hàng thành công'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thêm sản phẩm vào giỏ hàng.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chi tiết sản phẩm',
          style: AppTextStyles.headingMedium.copyWith(color: textColor),
        ),
      ),
      body: FutureBuilder<ProductModel>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ProductErrorState(onRetry: _retry);
          }

          return _ProductDetailContent(
            product: snapshot.data!,
            isAddingToCart: _isAddingToCart,
            onAddToCart: () => _addToCart(snapshot.data!),
          );
        },
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final ProductModel product;
  final bool isAddingToCart;
  final VoidCallback onAddToCart;

  const _ProductDetailContent({
    required this.product,
    required this.isAddingToCart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageUrl: product.imageUrl),
          Container(
            width: double.infinity,
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                AppSpacing.h16,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: mutedColor,
                          ),
                          AppSpacing.w8,
                          Flexible(
                            child: Text(
                              'Kho: ${product.stockQuantity}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: mutedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.w16,
                    Text(
                      _formatPrice(product.price),
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mô tả',
                  style: AppTextStyles.headingMedium.copyWith(color: textColor),
                ),
                AppSpacing.h8,
                ExpandableDescription(
                  description: product.description,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.xLarge,
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ShopAvatar(
                    avatarUrl: product.shop.avatarUrl,
                    shopName: product.shop.name,
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.shop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          product.shop.description.isEmpty
                              ? 'Shop chưa có mô tả.'
                              : product.shop.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: mutedColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: isAddingToCart ? null : onAddToCart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.65,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.xLarge),
                ),
                icon: isAddingToCart
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add_shopping_cart_outlined),
                label: Text(
                  isAddingToCart ? 'Đang thêm...' : 'Thêm vào giỏ hàng',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final value = price.toStringAsFixed(0);
    final formatted = value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$formattedđ';
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    if (imageUrl.isEmpty) {
      return _ImagePlaceholder(color: placeholderColor);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: placeholderColor,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, _, _) => _ImagePlaceholder(color: placeholderColor),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Color color;

  const _ImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ColoredBox(
        color: color,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _ShopAvatar extends StatelessWidget {
  final String avatarUrl;
  final String shopName;

  const _ShopAvatar({required this.avatarUrl, required this.shopName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;
    final fallback = Center(
      child: Text(
        shopName.isEmpty ? 'S' : shopName.substring(0, 1).toUpperCase(),
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
      ),
    );

    return CircleAvatar(
      radius: AppSpacing.xl,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? SizedBox.expand(child: fallback)
            : Image.network(
                avatarUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class ExpandableDescription extends StatefulWidget {
  final String description;
  final Color textColor;
  final Color mutedColor;

  const ExpandableDescription({
    super.key,
    required this.description,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.description.trim().isEmpty) {
      return Text(
        'Sản phẩm chưa có mô tả.',
        style: AppTextStyles.bodyMedium.copyWith(color: widget.mutedColor),
      );
    }

    final textStyle = AppTextStyles.bodyMedium.copyWith(
      color: widget.textColor,
      height: 1.55,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.description, style: textStyle),
          maxLines: 3,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final canExpand = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                widget.description,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
            if (canExpand || _isExpanded) ...[
              AppSpacing.h4,
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: AppRadius.small,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    _isExpanded ? 'Thu gọn' : 'Xem thêm',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProductErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProductErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: mutedColor),
            AppSpacing.h16,
            Text(
              'Không thể tải sản phẩm',
              style: AppTextStyles.headingMedium.copyWith(color: textColor),
            ),
            AppSpacing.h8,
            Text(
              'Vui lòng kiểm tra kết nối và thử lại.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            ),
            AppSpacing.h16,
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
