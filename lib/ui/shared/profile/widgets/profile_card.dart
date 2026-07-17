import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const ProfileCard({
    super.key,
    required this.child,
    required this.isDark,
    required this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.xLarge,
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
