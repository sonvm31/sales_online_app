import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/logic/notification/notification_controller.dart';
import 'package:sales_online_app/ui/buyer/cart/cart_screen.dart';
import 'package:sales_online_app/ui/shared/chat_list_screen.dart';
import 'package:sales_online_app/ui/buyer/tabs/home_tab.dart';
import 'package:sales_online_app/ui/shared/profile_screen.dart';
import 'package:sales_online_app/main.dart';

import 'package:sales_online_app/data/services/shop_service.dart';

class MainWrapperScreen extends StatefulWidget {
  final AuthController controller; // Thêm dòng này
  const MainWrapperScreen({super.key, required this.controller});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreen();
}

class _MainWrapperScreen extends State<MainWrapperScreen> with WidgetsBindingObserver {
  late final CartController _cartController;
  late final NotificationController _notificationController;
  int _currIndex = 0;
  late final String _currentUserId;
  String? _presenceId;

  List<Widget> get _tabs => [
    HomeTab(
      controller: widget.controller,
      cartController: _cartController,
      notificationController: _notificationController,
      onTabSelected: _selectTab,
    ),
    CartScreen(controller: _cartController),
    const ChatListScreen(),
    ProfileScreen(controller: widget.controller), // Truyền controller vào đây
  ];

  void _selectTab(int index) {
    if (!mounted) return;
    setState(() => _currIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentUserId = widget.controller.session?.userId?.toString() ?? "unknown_user";
    _cartController = CartController(userId: widget.controller.session?.userId);
    _notificationController = NotificationController(
      role: widget.controller.session?.role ?? 'BUYER',
    );
    _cartController.loadCart();
    _notificationController.initialize();
    _setupPresence();
  }

  Future<void> _setupPresence() async {
    final session = widget.controller.session;
    if (session == null) return;

    if (session.role.toUpperCase() == 'SELLER') {
      try {
        final shop = await ShopService().fetchShopByOwner(session.userId!);
        _presenceId = shop.id.toString();
      } catch (e) {
        _presenceId = session.userId?.toString();
      }
    } else {
      _presenceId = session.userId?.toString();
    }

    if (_presenceId != null) {
      _updatePresence(true);
    }
  }

  Future<void> _updatePresence(bool isOnline) async {
    if (_presenceId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('user_presence')
          .doc(_presenceId!)
          .set({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating presence: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePresence(true);
    } else {
      _updatePresence(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updatePresence(false);
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
            icon: _ChatNavIcon(currentUserId: _currentUserId),
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

class _ChatNavIcon extends StatefulWidget {
  final String currentUserId;

  const _ChatNavIcon({
    required this.currentUserId,
  });

  @override
  State<_ChatNavIcon> createState() => _ChatNavIconState();
}

class _ChatNavIconState extends State<_ChatNavIcon> {
  bool _isLoading = true;
  String _resolvedUserId = "unknown_user";

  @override
  void initState() {
    super.initState();
    _resolveChatUserId();
  }

  Future<void> _resolveChatUserId() async {
    final session = authController.session;
    if (session == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final userId = session.userId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (session.role.toUpperCase() == 'SELLER') {
      try {
        final shop = await ShopService().fetchShopByOwner(userId);
        if (mounted) {
          setState(() {
            _resolvedUserId = shop.id.toString();
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error resolving shopId for nav icon: $e");
        if (mounted) {
          setState(() {
            _resolvedUserId = widget.currentUserId;
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _resolvedUserId = widget.currentUserId;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const icon = Icon(CupertinoIcons.conversation_bubble);

    if (_isLoading) {
      return icon;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('members', arrayContains: _resolvedUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return icon;

        final int unreadCount = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String lastSenderId = data['lastSenderId']?.toString() ?? "";
          final bool hasUnread = data['hasUnread'] as bool? ?? false;
          return hasUnread && (lastSenderId != _resolvedUserId);
        }).length;

        if (unreadCount <= 0) {
          return icon;
        }

        return Badge(
          label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
          backgroundColor: Colors.red,
          child: icon,
        );
      },
    );
  }
}
