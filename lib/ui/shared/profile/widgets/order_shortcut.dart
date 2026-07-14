import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class OrderShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const OrderShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xLarge,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                child: Icon(icon, color: textColor),
              ),
              AppSpacing.h8,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: textColor,
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
