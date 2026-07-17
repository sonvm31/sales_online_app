import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class SellerActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color tintColor;
  final bool isDark;
  final VoidCallback onTap;

  const SellerActionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.tintColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: AppRadius.xLarge,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xLarge,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.xLarge,
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
              AppSpacing.h8,
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
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
