import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';

class CartScreen extends StatefulWidget {
  final CartController controller;

  const CartScreen({super.key, required this.controller});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<int> _selectedItemIds = <int>{};

  CartController get controller => widget.controller;

  Future<void> _clearCart(BuildContext context) async {
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

    if (shouldClear != true) return;

    try {
      await controller.clearCart();
      _selectedItemIds.clear();
      if (!context.mounted) return;
      _showSnackBar(context, 'Đã xóa giỏ hàng.');
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Không thể xóa giỏ hàng.');
    }
  }

  Future<void> _updateQuantity(
    BuildContext context,
    CartItemModel item,
    int nextQuantity,
  ) async {
    try {
      await controller.updateQuantity(
        cartItemId: item.id,
        quantity: nextQuantity,
      );
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Không thể cập nhật số lượng.');
    }
  }

  Future<void> _removeItem(BuildContext context, CartItemModel item) async {
    try {
      await controller.removeItem(item.id);
      _selectedItemIds.remove(item.id);
      if (!context.mounted) return;
      _showSnackBar(context, 'Đã xóa sản phẩm khỏi giỏ hàng.');
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Không thể xóa sản phẩm.');
    }
  }

  void _toggleItemSelection(CartItemModel item, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedItemIds.add(item.id);
      } else {
        _selectedItemIds.remove(item.id);
      }
    });
  }

  void _toggleSelectAll(List<CartItemModel> items, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedItemIds
          ..clear()
          ..addAll(items.map((item) => item.id));
      } else {
        _selectedItemIds.clear();
      }
    });
  }

  void _syncSelection(List<CartItemModel> items) {
    final itemIds = items.map((item) => item.id).toSet();
    _selectedItemIds.removeWhere((id) => !itemIds.contains(id));
  }

  bool _isAllSelected(List<CartItemModel> items) {
    return items.isNotEmpty && _selectedItemIds.length == items.length;
  }

  void _showSnackBar(BuildContext context, String message) {
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
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              _syncSelection(controller.items);
              if (!_isAllSelected(controller.items)) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: TextButton.icon(
                  onPressed: controller.isClearing
                      ? null
                      : () => _clearCart(context),
                  icon: controller.isClearing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: const Text('Xóa giỏ hàng'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (!controller.hasValidUser) {
            return _RefreshableMessage(
              onRefresh: controller.loadCart,
              child: const _CartMessage(
                icon: Icons.person_off_outlined,
                title: 'Không xác định được người dùng',
                message: 'Vui lòng đăng nhập lại để xem giỏ hàng.',
              ),
            );
          }

          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.errorMessage != null) {
            return _RefreshableMessage(
              onRefresh: controller.loadCart,
              child: _CartErrorState(onRetry: controller.loadCart),
            );
          }

          if (controller.items.isEmpty) {
            return _RefreshableMessage(
              onRefresh: controller.loadCart,
              child: const _CartMessage(
                icon: Icons.shopping_cart_outlined,
                title: 'Giỏ hàng đang trống',
                message: 'Hãy thêm sản phẩm bạn muốn mua vào giỏ hàng.',
              ),
            );
          }

          _syncSelection(controller.items);
          final selectedItems = controller.items
              .where((item) => _selectedItemIds.contains(item.id))
              .toList();
          final selectedTotal = selectedItems.fold<double>(
            0,
            (sum, item) => sum + item.totalPrice,
          );
          final isAllSelected = _isAllSelected(controller.items);

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadCart,
                  color: AppColors.primary,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, _) => AppSpacing.h16,
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      return _CartItemTile(
                        item: item,
                        isSelected: _selectedItemIds.contains(item.id),
                        isUpdating: controller.isUpdating(item.id),
                        onSelectedChanged: (value) =>
                            _toggleItemSelection(item, value),
                        onDecrease: () =>
                            _updateQuantity(context, item, item.quantity - 1),
                        onIncrease: () =>
                            _updateQuantity(context, item, item.quantity + 1),
                        onRemove: () => _removeItem(context, item),
                      );
                    },
                  ),
                ),
              ),
              _CartSummary(
                total: selectedTotal,
                selectedCount: selectedItems.length,
                isAllSelected: isAllSelected,
                onSelectAllChanged: (value) =>
                    _toggleSelectAll(controller.items, value),
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
  final bool isSelected;
  final bool isUpdating;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.isSelected,
    required this.isUpdating,
    required this.onSelectedChanged,
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
        borderRadius: AppRadius.xLarge,
        border: Border.all(color: borderColor.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 18, color: mutedColor),
              AppSpacing.w8,
              Expanded(
                child: Text(
                  item.product.shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: isUpdating ? null : onSelectedChanged,
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
              AppSpacing.w8,
              _CartProductImage(imageUrl: item.product.imageUrl),
              AppSpacing.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      _formatPrice(item.product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.h16,
                    _QuantityStepper(
                      quantity: item.quantity,
                      isUpdating: isUpdating,
                      textColor: textColor,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                  ],
                ),
              ),
              AppSpacing.w8,
              IconButton.filledTonal(
                tooltip: 'Xóa',
                onPressed: isUpdating ? null : onRemove,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.08),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                ),
                icon: const Icon(Icons.delete_outline, size: 20),
              ),
            ],
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
      borderRadius: AppRadius.large,
      child: SizedBox(
        width: 88,
        height: 88,
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

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool isUpdating;
  final Color textColor;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityStepper({
    required this.quantity,
    required this.isUpdating,
    required this.textColor,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: 116,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.circular,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove,
            onPressed: isUpdating ? null : onDecrease,
          ),
          Expanded(
            child: Center(
              child: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '$quantity',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onPressed: isUpdating ? null : onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final int selectedCount;
  final bool isAllSelected;
  final ValueChanged<bool?> onSelectAllChanged;

  const _CartSummary({
    required this.total,
    required this.selectedCount,
    required this.isAllSelected,
    required this.onSelectAllChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  onChanged: onSelectAllChanged,
                  activeColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  'Chọn tất cả',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.h8,
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thanh toán',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: mutedColor,
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        _formatPrice(total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 54,
                  child: FilledButton(
                    onPressed: selectedCount == 0 ? null : () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: const Color(0xFFD3D8E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.xLarge,
                      ),
                    ),
                    child: Text(
                      selectedCount == 0
                          ? 'Mua hàng'
                          : 'Mua hàng ($selectedCount)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshableMessage extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _RefreshableMessage({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.68,
            child: child,
          ),
        ],
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
