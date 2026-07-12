import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class TrackingTimelineStep extends StatelessWidget {
  final String title;
  final bool isDone;
  final bool isLast;

  const TrackingTimelineStep({
    super.key,
    required this.title,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final color = isDone ? AppColors.primary : mutedColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color.withValues(alpha: isDone ? 1 : 0.18),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.circle_outlined,
                color: isDone ? Colors.white : color,
                size: 15,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: color.withValues(alpha: 0.35),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDone ? textColor : mutedColor,
                fontWeight: isDone ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
