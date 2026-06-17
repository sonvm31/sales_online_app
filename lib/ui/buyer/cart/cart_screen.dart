import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/data/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  final int? userId;
  final CartService? cartService;

  const CartScreen({super.key, required this.userId, this.cartService});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartService _cartService;
  late Future<List<CartItemModel>> _cartFuture;
  final Set<int> _updatingItemIds = <int>{};
  bool _isClearing = false;

  bool get _hasValidUser => widget.userId != null && widget.userId! > 0;

  @override
  void initState() {
    super.initState();
    _cartService = widget.cartService ?? CartService();
    _loadCart();
  }

  @override
  void didUpdateWidget(covariant CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadCart();
    }
  }

  void _loadCart() {
    _cartFuture = _hasValidUser
        ? _cartService.fetchCart(widget.userId!)
        : Future<List<CartItemModel>>.value(const <CartItemModel>[]);
  }

  void _refreshCart() {
    setState(_loadCart);
  }

  Future<void> _updateQuantity(CartItemModel item, int nextQuantity) async {
    if (nextQuantity < 1) {
      await _removeItem(item);
      return;
    }

    setState(() => _updatingItemIds.add(item.id));
    try {
      await _cartService.updateQuantity(
        cartItemId: item.id,
        quantity: nextQuantity,
      );
      _refreshCart();
    } catch (_) {
      _showSnackBar('Không thể cập nhật số lượng.');
    } finally {
      if (mounted) {
        setState(() => _updatingItemIds.remove(item.id));
      }
    }
  }

  Future<void> _removeItem(CartItemModel item) async {
    setState(() => _updatingItemIds.add(item.id));
    try {
      await _cartService.removeItem(item.id);
      _showSnackBar('Đã xóa sản phẩm khỏi giỏ hàng.');
      _refreshCart();
    } catch (_) {
      _showSnackBar('Không thể xóa sản phẩm.');
    } finally {
      if (mounted) {
        setState(() => _updatingItemIds.remove(item.id));
      }
    }
  }

  Future<void> _clearCart() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa giỏ hàng?'),
          content: const Text('Tất cả sản phẩm trong giỏ hàng sẽ bị xóa.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !_hasValidUser) return;

    setState(() => _isClearing = true);
    try {
      await _cartService.clearCart(widget.userId!);
      _showSnackBar('Đã xóa giỏ hàng.');
      _refreshCart();
    } catch (_) {
      _showSnackBar('Không thể xóa giỏ hàng.');
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giỏ hàng',
          style: AppTextStyles.headingMedium.copyWith(color: textColor),
        ),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _refreshCart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !_hasValidUser
          ? const _CartMessage(
              icon: Icons.person_off_outlined,
              title: 'Không xác định được người dùng',
              message: 'Vui lòng đăng nhập lại để xem giỏ hàng.',
            )
          : FutureBuilder<List<CartItemModel>>(
              future: _cartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return _CartErrorState(onRetry: _refreshCart);
                }

                final items = snapshot.data ?? const <CartItemModel>[];
                if (items.isEmpty) {
                  return const _CartMessage(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Giỏ hàng đang trống',
                    message: 'Hãy thêm sản phẩm bạn muốn mua vào giỏ hàng.',
                  );
                }

                final total = items.fold<double>(
                  0,
                  (sum, item) => sum + item.totalPrice,
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => AppSpacing.h16,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CartItemTile(
                            item: item,
                            isUpdating: _updatingItemIds.contains(item.id),
                            onDecrease: () =>
                                _updateQuantity(item, item.quantity - 1),
                            onIncrease: () =>
                                _updateQuantity(item, item.quantity + 1),
                            onRemove: () => _removeItem(item),
                          );
                        },
                      ),
                    ),
                    _CartSummary(
                      total: total,
                      isClearing: _isClearing,
                      onClearCart: _clearCart,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool isUpdating;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.isUpdating,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.large,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CartProductImage(imageUrl: item.product.imageUrl),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Xóa',
                      onPressed: isUpdating ? null : onRemove,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  _formatPrice(item.product.price),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.h16,
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: isUpdating ? null : onDecrease,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: isUpdating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '${item.quantity}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: isUpdating ? null : onIncrease,
                    ),
                    const Spacer(),
                    Text(
                      _formatPrice(item.totalPrice),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _CartProductImage extends StatelessWidget {
  final String imageUrl;

  const _CartProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return ClipRRect(
      borderRadius: AppRadius.medium,
      child: SizedBox(
        width: 76,
        height: 76,
        child: imageUrl.isEmpty
            ? ColoredBox(
                color: placeholderColor,
                child: const Icon(Icons.image_not_supported_outlined),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: placeholderColor,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final bool isClearing;
  final VoidCallback onClearCart;

  const _CartSummary({
    required this.total,
    required this.isClearing,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng cộng',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    _formatPrice(total),
                    style: AppTextStyles.headingMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: isClearing ? null : onClearCart,
              icon: isClearing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep_outlined),
              label: const Text('Xóa giỏ hàng'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _CartMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

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
            Icon(icon, size: 56, color: mutedColor),
            AppSpacing.h16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium.copyWith(color: textColor),
            ),
            AppSpacing.h8,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _CartErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            AppSpacing.h16,
            Text('Không thể tải giỏ hàng', style: AppTextStyles.headingMedium),
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

String _formatPrice(double price) {
  final value = price.toStringAsFixed(0);
  final formatted = value.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '$formattedđ';
}
