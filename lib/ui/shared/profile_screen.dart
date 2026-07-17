import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/buyer/order/buyer_orders_screen.dart';
import 'package:sales_online_app/ui/buyer/shop/shop_screen.dart';
import 'package:sales_online_app/ui/seller/order_management_screen.dart';
import 'package:sales_online_app/ui/seller/product_management_screen.dart';
import 'package:sales_online_app/ui/seller/seller_report_screen.dart';
import 'package:sales_online_app/ui/shared/request_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AuthController controller;

  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool isSellerMode;

  @override
  void initState() {
    super.initState();
    isSellerMode = widget.controller.session?.role.toUpperCase() == 'SELLER';
  }

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    return widget.controller.session?.fullName?.trim().isNotEmpty == true
        ? widget.controller.session!.fullName!.trim()
        : user?.displayName ?? user?.email ?? 'Người dùng';
  }

  String get _shopName => 'Shop Của Tôi';

  void _openProductManagement() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductManagementScreen(
          shopId: widget.controller.session?.userId ?? 0,
          shopName: _shopName,
        ),
      ),
    );
  }

  void _openShopView() {
    final shop = ShopModel(
      id: widget.controller.session?.userId ?? 0,
      name: _shopName,
      description: 'Giao diện cửa hàng người mua sẽ nhìn thấy.',
      avatarUrl: '',
      isActive: true,
    );

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
    );
  }
}

class _BuyerHeader extends StatelessWidget {
  final String displayName;

  const _BuyerHeader({required this.displayName});

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 58, 28, 34),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF65E46F),
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Đã xác thực',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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

class _ModeCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final String currentMode;
  final String buttonText;
  final VoidCallback onPressed;

  const _ModeCard({
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.currentMode,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      isDark: isDark,
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ hiển thị',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: 'Đang dùng: ',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : const Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: currentMode,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 210),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFEAF2FF),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  buttonText,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color tintColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SellerActionTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.tintColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textLight : const Color(0xFF374151);

    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.16) : tintColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopPreviewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShopPreviewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF172132),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 26, 22, 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.13),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trang hiển thị Shop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Xem giao diện khách hàng nhìn thấy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFB7C0CF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFB7C0CF),
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color color;
  final EdgeInsetsGeometry padding;

  const _ProfileCard({
    required this.child,
    required this.isDark,
    required this.color,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _OrderShortcut({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textLight : const Color(0xFF374151);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isDark
                    ? AppColors.backgroundDark
                    : const Color(0xFFF3F4F6),
                child: Icon(icon, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color:
          textColor ??
              (isDark ? AppColors.textLight : const Color(0xFF1F2937)),
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}