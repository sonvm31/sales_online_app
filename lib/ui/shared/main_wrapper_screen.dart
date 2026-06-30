import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/logic/notification/notification_controller.dart';
import 'package:sales_online_app/ui/buyer/cart/cart_screen.dart';
import 'package:sales_online_app/ui/buyer/tabs/home_tab.dart';
import 'package:sales_online_app/ui/shared/temp_screen.dart';
import 'package:sales_online_app/ui/shared/profile_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  final AuthController controller; // Thêm dòng này
  const MainWrapperScreen({super.key, required this.controller});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreen();
}

class _MainWrapperScreen extends State<MainWrapperScreen> {
  late final CartController _cartController;
  late final NotificationController _notificationController;
  int _currIndex = 0;

  List<Widget> get _tabs => [
    HomeTab(
      controller: widget.controller,
      cartController: _cartController,
      notificationController: _notificationController,
      onTabSelected: _selectTab,
    ),
    CartScreen(controller: _cartController),
    const PlaceholderScreen(title: "Màn hình Tin nhắn"),
    ProfileScreen(controller: widget.controller), // Truyền controller vào đây
  ];

  void _selectTab(int index) {
    if (!mounted) return;
    setState(() => _currIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _cartController = CartController(userId: widget.controller.session?.userId);
    _notificationController = NotificationController(
      role: widget.controller.session?.role ?? 'BUYER',
    );
    _cartController.loadCart();
    _notificationController.initialize();
  }

  @override
  void dispose() {
    _cartController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _currIndex, children: _tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currIndex,
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
        onTap: _selectTab,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: ListenableBuilder(
              listenable: _cartController,
              builder: (context, child) {
                return _CartNavIcon(count: _cartController.itemCount);
              },
            ),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.conversation_bubble),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  final int count;

  const _CartNavIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    const icon = Icon(CupertinoIcons.shopping_cart);

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
