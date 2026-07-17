import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class MenuOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const MenuOption({
    super.key,
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
          borderRadius: AppRadius.large,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color:
              textColor ?? (isDark ? AppColors.textLight : AppColors.textDark),
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}
