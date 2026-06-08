import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/tabs/home_tab.dart';
import 'package:sales_online_app/ui/shared/temp_screen.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/shared/profile_screen.dart';
class MainWrapperScreen extends StatefulWidget{
  final AuthController controller; // Thêm dòng này
  const MainWrapperScreen({super.key, required this.controller});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreen();
}

class _MainWrapperScreen extends State<MainWrapperScreen>{
  int _currIndex = 0;

  List<Widget> get _tabs => [
    const HomeTab(),
    const PlaceholderScreen(title: "Màn hình giỏ hàng"),
    const PlaceholderScreen(title: "Màn hình Tin nhắn"),
    ProfileScreen(controller: widget.controller), // Truyền controller vào đây
  ];

  @override
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        iconSize: 24,
        onTap: (index) => setState(() => _currIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('1'),
              backgroundColor: Colors.red,
              child: Icon(CupertinoIcons.shopping_cart),
            ),
            label: 'Giỏ hàng'
          ),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.conversation_bubble), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}