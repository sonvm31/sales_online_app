import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/menu_option.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/mode_card.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/profile_card.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/seller_action_tile.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/seller_header.dart';
import 'package:sales_online_app/ui/shared/profile/widgets/shop_preview_button.dart';

class SellerProfileView extends StatelessWidget {
  final String shopName;
  final bool isShopActive;
  final bool isLoadingShop;
  final String? shopErrorMessage;
  final bool isDarkThemeEnabled;
  final VoidCallback onRetryShop;
  final VoidCallback onSwitchToBuyer;
  final VoidCallback onOpenProducts;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenShopPreview;
  final VoidCallback onOpenSupportCenter;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const SellerProfileView({
    super.key,
    required this.shopName,
    required this.isShopActive,
    required this.isLoadingShop,
    required this.shopErrorMessage,
    required this.isDarkThemeEnabled,
    required this.onRetryShop,
    required this.onSwitchToBuyer,
    required this.onOpenProducts,
    required this.onOpenOrders,
    required this.onOpenReport,
    required this.onOpenShopPreview,
    required this.onOpenSupportCenter,
    required this.onToggleTheme,
    required this.onLogout,
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
              SellerHeader(
                shopName: shopName,
                isActive: isShopActive,
                isLoading: isLoadingShop,
                errorMessage: shopErrorMessage,
                onRetry: onRetryShop,
              ),
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
                      currentMode: 'Người bán',
                      buttonText: 'Chuyển sang BUYER',
                      onPressed: onSwitchToBuyer,
                    ),
                    AppSpacing.h24,
                    _SectionTitle(text: 'QUẢN LÝ CỬA HÀNG', color: textColor),
                    AppSpacing.h16,
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.12,
                      children: [
                        SellerActionTile(
                          title: 'Sản phẩm của tôi',
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFFFF6A00),
                          tintColor: const Color(0xFFFFF4E6),
                          isDark: isDark,
                          onTap: onOpenProducts,
                        ),
                        SellerActionTile(
                          title: 'Đơn hàng mới',
                          icon: CupertinoIcons.list_bullet,
                          iconColor: const Color(0xFFA855F7),
                          tintColor: const Color(0xFFF6ECFF),
                          isDark: isDark,
                          onTap: onOpenOrders,
                        ),
                        SellerActionTile(
                          title: 'Doanh thu',
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFF22C55E),
                          tintColor: const Color(0xFFEAFBF1),
                          isDark: isDark,
                          onTap: onOpenReport,
                        ),
                      ],
                    ),
                    AppSpacing.h24,
                    ShopPreviewButton(onTap: onOpenShopPreview),
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
