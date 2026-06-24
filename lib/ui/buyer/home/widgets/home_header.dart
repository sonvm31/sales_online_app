import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final int notificationCount;

  const HomeHeader({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xLarge.topLeft.x * 2),
          bottomRight: Radius.circular(AppRadius.xLarge.topRight.x * 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: AppRadius.circular,
                ),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.search, color: Colors.white, size: 24),
                    AppSpacing.w8,
                    Expanded(
                      child: Text(
                        "Tìm kiếm sản phẩm ...",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.whitePlaceholder,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.w16,
          InkWell(
            onTap: onNotificationTap,
            borderRadius: AppRadius.circular,
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.rectangle,
                borderRadius: AppRadius.xLarge,
              ),
              child: Badge(
                isLabelVisible: notificationCount > 0,
                label: Text(
                  notificationCount > 99 ? '99+' : '$notificationCount',
                ),
                backgroundColor: Colors.red,
                child: const Icon(
                  CupertinoIcons.bell,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
