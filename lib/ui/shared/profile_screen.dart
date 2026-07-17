import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/logic/profile/profile_controller.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/buyer/order/buyer_orders_screen.dart';
import 'package:sales_online_app/ui/buyer/shop/shop_screen.dart';
import 'package:sales_online_app/ui/seller/order_management_screen.dart';
import 'package:sales_online_app/ui/seller/product_management_screen.dart';
import 'package:sales_online_app/ui/seller/seller_report_screen.dart';
import 'package:sales_online_app/ui/shared/request_support_screen.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/buyer_profile_view.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/seller_profile_view.dart';

class ProfileScreen extends StatefulWidget {
  final AuthController controller;

  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(authController: widget.controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _ensureShopReady() {
    if (_controller.shopId > 0) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          _controller.shopErrorMessage ??
              'Đang tải thông tin shop, vui lòng thử lại.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    if (!_controller.isLoadingShop) {
      _controller.loadSellerShop();
    }
    return false;
  }

  void _openProductManagement() {
    if (!_ensureShopReady()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductManagementScreen(
          shopId: _controller.shopId,
          shopName: _controller.shopName,
        ),
      ),
    );
  }

  void _openOrderManagement() {
    if (!_ensureShopReady()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderManagementScreen(shopId: _controller.shopId),
      ),
    );
  }

  void _openSellerReport() {
    if (!_ensureShopReady()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerReportScreen(shopId: _controller.shopId),
      ),
    );
  }

  void _openShopView() {
    if (!_ensureShopReady()) return;
    final shop = _controller.sellerShop!;

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => ShopScreen(shop: shop)));
  }

  void _openBuyerOrders({required String title, String? statusFilter}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuyerOrdersScreen(
          userId: widget.controller.session?.userId,
          title: title,
          statusFilter: statusFilter,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await widget.controller.logout();
  }

  @override
  Widget build(BuildContext context) {
    return isSellerMode ? _buildSellerView(context) : _buildBuyerView(context);
  }

  Widget _buildSellerView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDark
        : const Color(0xFFF5F7FA);
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SellerHeader(shopName: _shopName),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ModeCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      currentMode: 'Người bán',
                      buttonText: 'Chuyển sang BUYER',
                      onPressed: () => setState(() => isSellerMode = false),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'QUẢN LÝ CỬA HÀNG',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.12,
                      children: [
                        _SellerActionTile(
                          title: 'Sản phẩm của tôi',
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFFFF6A00),
                          tintColor: const Color(0xFFFFF4E6),
                          isDark: isDark,
                          onTap: () => _openProductManagement(),
                        ),
                        _SellerActionTile(
                          title: 'Đơn hàng mới',
                          icon: CupertinoIcons.list_bullet,
                          iconColor: const Color(0xFFA855F7),
                          tintColor: const Color(0xFFF6ECFF),
                          isDark: isDark,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OrderManagementScreen(
                                shopId: widget.controller.session?.userId ?? 0,
                              ),
                            ),
                          ),
                        ),
                        _SellerActionTile(
                          title: 'Doanh thu',
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFF22C55E),
                          tintColor: const Color(0xFFEAFBF1),
                          isDark: isDark,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SellerReportScreen(
                                shopId: widget.controller.session?.userId ?? 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _ShopPreviewButton(onTap: _openShopView),
                    const SizedBox(height: 24),
                    Text(
                      'TIỆN ÍCH KHÁC',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileCard(
                      isDark: isDark,
                      color: cardColor,
                      child: Column(
                        children: [
                          _MenuOption(
                            icon: CupertinoIcons.tickets,
                            iconColor: AppColors.primary,
                            title: 'Trung tâm hỗ trợ',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RequestSupportScreen(
                                    isSeller: true
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            height: 20,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: isDark ? Colors.amber : Colors.orange,
                            ),
                            title: Text(
                              'Chế độ tối',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            activeThumbColor: AppColors.primary,
                            value: themeProvider.currTheme == ThemeMode.dark,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            height: 20,
                          ),
                          _MenuOption(
                            icon: Icons.logout,
                            iconColor: Colors.red,
                            title: 'Đăng xuất tài khoản',
                            textColor: Colors.red,
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyerView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDark
        : const Color(0xFFF5F7FA);
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BuyerHeader(displayName: _displayName),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ModeCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      currentMode: 'Người mua',
                      buttonText: 'Chuyển sang SELLER',
                      onPressed: () => setState(() => isSellerMode = true),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ĐƠN MUA CỦA TÔI',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileCard(
                      isDark: isDark,
                      color: cardColor,
                      child: Row(
                        children: [
                          _OrderShortcut(
                            icon: CupertinoIcons.time,
                            label: 'Chờ xác nhận',
                            isDark: isDark,
                            onTap: () => _openBuyerOrders(
                              title: 'Chờ xác nhận',
                              statusFilter: 'PENDING',
                            ),
                          ),
                          _OrderShortcut(
                            icon: CupertinoIcons.cube_box,
                            label: 'Đang giao',
                            isDark: isDark,
                            onTap: () => _openBuyerOrders(
                              title: 'Đang giao',
                              statusFilter: 'SHIPPING',
                            ),
                          ),
                          _OrderShortcut(
                            icon: CupertinoIcons.check_mark_circled,
                            label: 'Hoàn thành',
                            isDark: isDark,
                            onTap: () => _openBuyerOrders(
                              title: 'Hoàn thành',
                              statusFilter: 'DONE',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'TIỆN ÍCH KHÁC',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileCard(
                      isDark: isDark,
                      color: cardColor,
                      child: Column(
                        children: [
                          _MenuOption(
                            icon: CupertinoIcons.tickets,
                            iconColor: AppColors.primary,
                            title: 'Trung tâm hỗ trợ',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RequestSupportScreen(
                                    isSeller: true
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            height: 20,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: isDark ? Colors.amber : Colors.orange,
                            ),
                            title: Text(
                              'Chế độ tối',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            activeThumbColor: AppColors.primary,
                            value: themeProvider.currTheme == ThemeMode.dark,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            height: 20,
                          ),
                          _MenuOption(
                            icon: Icons.logout,
                            iconColor: Colors.red,
                            title: 'Đăng xuất tài khoản',
                            textColor: Colors.red,
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerHeader extends StatelessWidget {
  final String shopName;

  const _SellerHeader({required this.shopName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 218,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
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
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(34, 62, 28, 40),
              child: Row(
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
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
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: Color(0xFF65E46F),
                              size: 16,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Đã xác thực',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
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
          ),
        ],
      ),
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isSellerMode) {
          return SellerProfileView(
            shopName: _controller.shopName,
            isLoadingShop: _controller.isLoadingShop,
            shopErrorMessage: _controller.shopErrorMessage,
            isDarkThemeEnabled: themeProvider.currTheme == ThemeMode.dark,
            onRetryShop: _controller.loadSellerShop,
            onSwitchToBuyer: _controller.switchToBuyer,
            onOpenProducts: _openProductManagement,
            onOpenOrders: _openOrderManagement,
            onOpenReport: _openSellerReport,
            onOpenShopPreview: _openShopView,
            onToggleTheme: themeProvider.toggleTheme,
            onLogout: _logout,
          );
        }

        return BuyerProfileView(
          displayName: _controller.displayName,
          isDarkThemeEnabled: themeProvider.currTheme == ThemeMode.dark,
          onSwitchToSeller: _controller.switchToSeller,
          onToggleTheme: themeProvider.toggleTheme,
          onLogout: _logout,
          onOpenOrders: _openBuyerOrders,
        );
      },
    );
  }
}
