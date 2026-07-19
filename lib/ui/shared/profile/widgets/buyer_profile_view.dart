import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/logic/profile/profile_controller.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/buyer_header.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/menu_option.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/mode_card.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/order_shortcut.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/profile_card.dart';

class BuyerProfileView extends StatelessWidget {
  final String displayName;
  final ShopRegistrationState shopRegistrationState;
  final bool isLoadingShop;
  final bool isDarkThemeEnabled;
  final VoidCallback onRegisterShop;
  final VoidCallback onSwitchToSeller;
  final VoidCallback onOpenSupportCenter;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final void Function({required String title, String? statusFilter})
  onOpenOrders;

  const BuyerProfileView({
    super.key,
    required this.displayName,
    required this.shopRegistrationState,
    required this.isLoadingShop,
    required this.isDarkThemeEnabled,
    required this.onRegisterShop,
    required this.onSwitchToSeller,
    required this.onOpenSupportCenter,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onOpenOrders,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuyerHeader(displayName: displayName),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModeCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      title: 'Kênh người bán',
                      statusLabel: '',
                      currentMode: _sellerModeDescription,
                      buttonText: _sellerModeButtonText,
                      onPressed: _sellerModeAction,
                    ),
                    AppSpacing.h24,
                    _SectionTitle(text: 'ĐƠN MUA CỦA TÔI', color: textColor),
                    AppSpacing.h8,
                    ProfileCard(
                      isDark: isDark,
                      color: cardColor,
                      child: Row(
                        children: [
                          OrderShortcut(
                            icon: CupertinoIcons.time,
                            label: 'Chờ xác nhận',
                            isDark: isDark,
                            onTap: () => onOpenOrders(
                              title: 'Chờ xác nhận',
                              statusFilter: 'PENDING',
                            ),
                          ),
                          OrderShortcut(
                            icon: CupertinoIcons.cube_box,
                            label: 'Đang giao',
                            isDark: isDark,
                            onTap: () => onOpenOrders(
                              title: 'Đang giao',
                              statusFilter: 'SHIPPING',
                            ),
                          ),
                          OrderShortcut(
                            icon: CupertinoIcons.check_mark_circled,
                            label: 'Hoàn thành',
                            isDark: isDark,
                            onTap: () => onOpenOrders(
                              title: 'Hoàn thành',
                              statusFilter: 'DONE',
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h24,
                    _SectionTitle(text: 'TIỆN ÍCH KHÁC', color: textColor),
                    AppSpacing.h8,
                    _UtilityCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      isDarkThemeEnabled: isDarkThemeEnabled,
                      onOpenSupportCenter: onOpenSupportCenter,
                      onToggleTheme: onToggleTheme,
                      onLogout: onLogout,
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

  String get _sellerModeDescription {
    if (isLoadingShop) return 'Đang kiểm tra trạng thái shop...';

    return switch (shopRegistrationState) {
      ShopRegistrationState.notRegistered => 'Đăng ký shop để bắt đầu bán hàng',
      ShopRegistrationState.pending => 'Đăng ký shop đang chờ admin duyệt',
      ShopRegistrationState.active => 'Shop đã được duyệt',
      ShopRegistrationState.locked =>
        'Shop đang bị khóa, vui lòng liên hệ hỗ trợ',
    };
  }

  String get _sellerModeButtonText {
    if (isLoadingShop) return 'Đang tải';

    return switch (shopRegistrationState) {
      ShopRegistrationState.notRegistered => 'Bắt đầu bán hàng',
      ShopRegistrationState.pending => 'Chờ duyệt',
      ShopRegistrationState.active => 'Chuyển sang SELLER',
      ShopRegistrationState.locked => 'Liên hệ hỗ trợ',
    };
  }

  VoidCallback? get _sellerModeAction {
    if (isLoadingShop) return null;

    return switch (shopRegistrationState) {
      ShopRegistrationState.notRegistered => onRegisterShop,
      ShopRegistrationState.pending => null,
      ShopRegistrationState.active => onSwitchToSeller,
      ShopRegistrationState.locked => onOpenSupportCenter,
    };
  }
}

class _UtilityCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final bool isDarkThemeEnabled;
  final VoidCallback onOpenSupportCenter;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const _UtilityCard({
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.isDarkThemeEnabled,
    required this.onOpenSupportCenter,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      isDark: isDark,
      color: cardColor,
      child: Column(
        children: [
          MenuOption(
            icon: CupertinoIcons.tickets,
            iconColor: AppColors.primary,
            title: 'Trung tâm hỗ trợ',
            onTap: onOpenSupportCenter,
          ),
          Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            activeThumbColor: AppColors.primary,
            value: isDarkThemeEnabled,
            onChanged: (_) => onToggleTheme(),
          ),
          Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            height: 20,
          ),
          MenuOption(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Đăng xuất tài khoản',
            textColor: Colors.red,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.headingMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}
