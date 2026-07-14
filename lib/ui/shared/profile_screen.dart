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
