import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/services/product_service.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/ui/buyer/chat/chat_screen.dart';
import 'package:sales_online_app/ui/buyer/home/widgets/product_card.dart';
import 'package:sales_online_app/ui/buyer/product_detail/product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  final ShopModel shop;
  final CartController? cartController;
  final ProductService? productService;
  final ValueChanged<int>? onTabSelected;

  const ShopScreen({
    super.key,
    required this.shop,
    this.cartController,
    this.productService,
    this.onTabSelected,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final ProductService _productService;
  final ScrollController _scrollController = ScrollController();
  final List<ProductModel> _products = <ProductModel>[];

  int _currentPage = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _productService = widget.productService ?? ProductService();
    _scrollController.addListener(_onScroll);
    _loadInitialProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    if (_isLoading) return;

    setState(() {
      _currentPage = 0;
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
      _products.clear();
    });

    try {
      final result = await _productService.searchProducts(
        shopId: widget.shop.id,
        page: _currentPage,
        size: 10,
      );
      if (!mounted) return;
      setState(() {
        _products.addAll(result['products'] as List<ProductModel>);
        _hasMore = !(result['isLast'] as bool);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải sản phẩm của cửa hàng.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _productService.searchProducts(
        shopId: widget.shop.id,
        page: nextPage,
        size: 10,
      );
      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _products.addAll(result['products'] as List<ProductModel>);
        _hasMore = !(result['isLast'] as bool);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 120) {
      _loadMoreProducts();
    }
  }

  void _openProduct(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          productId: product.id,
          cartController: widget.cartController,
          productService: _productService,
          onTabSelected: widget.onTabSelected,
        ),
      ),
    );
  }

  void _navigateToChat() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          receiverId: widget.shop.id?.toString() ?? "unknown_shop",
          receiverName: widget.shop.name ?? "Cửa hàng",
        ),
      ),
    );
  }

  void _handleBottomNavigationTap(int index) {
    if (index == 2) {
      _navigateToChat();
      return;
    }
    widget.onTabSelected?.call(index);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.shop.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headingMedium.copyWith(color: textColor),
        ),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialProducts,
        color: AppColors.primary,
        backgroundColor: Theme.of(context).cardColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _ShopHeader(shop: widget.shop, onChatTap: _navigateToChat),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  'Sản phẩm của cửa hàng',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ShopMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'Không thể tải cửa hàng',
                  message: _errorMessage!,
                  actionLabel: 'Thử lại',
                  onAction: _loadInitialProducts,
                ),
              )
            else if (_products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _ShopMessage(
                  icon: Icons.inventory_2_outlined,
                  title: 'Chưa có sản phẩm',
                  message: 'Cửa hàng này hiện chưa có sản phẩm đang bán.',
                ),
              )
            else ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = _products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _openProduct(product),
                    );
                  }, childCount: _products.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600
                        ? 3
                        : 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                ),
              ),
              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
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
                ),
              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: widget.onTabSelected == null
          ? null
          : _ShopBottomNavigationBar(
              cartController: widget.cartController,
              onTap: _handleBottomNavigationTap,
            ),
    );
  }
}

class _ShopBottomNavigationBar extends StatelessWidget {
  final CartController? cartController;
  final ValueChanged<int> onTap;

  const _ShopBottomNavigationBar({
    required this.cartController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(
        context,
      ).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark
          ? AppColors.textMutedDark
          : AppColors.textMutedLight,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      iconSize: 24,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: cartController == null
              ? const Icon(Icons.shopping_cart_outlined)
              : ListenableBuilder(
                  listenable: cartController!,
                  builder: (context, child) {
                    return _ShopCartNavIcon(count: cartController!.itemCount);
                  },
                ),
          label: 'Giỏ hàng',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Tin nhắn',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}

class _ShopCartNavIcon extends StatelessWidget {
  final int count;

  const _ShopCartNavIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.shopping_cart_outlined);

    if (count <= 0) {
      return icon;
    }

    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: Colors.red,
      child: icon,
    );
  }
}

class _ShopHeader extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onChatTap;

  const _ShopHeader({required this.shop, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShopAvatar(
            avatarUrl: shop.avatarUrl,
            shopName: shop.name,
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  shop.name ?? "Cửa hàng",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              AppSpacing.w8,
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  CupertinoIcons.conversation_bubble,
                                  color: AppColors.primary,
                                  size: 22.0.w,
                                ),
                                onPressed: onChatTap,
                              ),
                            ],
                          ),
                          AppSpacing.h4,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: (shop.isActive ?? false)
                                  ? Colors.green.withValues(alpha: 0.12)
                                  : borderColor,
                              borderRadius: AppRadius.circular,
                            ),
                            child: Text(
                              shop.isActive
                                  ? 'Đang bán'
                                  : 'Tạm nghỉ',
                              style: AppTextStyles.caption.copyWith(
                                color: shop.isActive
                                    ? Colors.green.shade700
                                    : mutedColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  shop.description.isEmpty
                      ? 'Cửa hàng chưa có mô tả.'
                      : shop.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: mutedColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
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

class _ShopMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ShopMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
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
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.h16,
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
