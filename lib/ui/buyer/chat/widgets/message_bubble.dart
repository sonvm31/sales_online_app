import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final Timestamp? timestamp;
  final bool isMe;
  final bool isDark;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    required this.isDark,
  });

  String _formatChatTime(Timestamp? ts) {
    if (ts == null) return '...';
    final DateTime localTime = ts.toDate().toLocal();
    return DateFormat('HH:mm').format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.primary
                : (isDark ? Colors.grey.shade800 : Colors.white),
            borderRadius: AppRadius.medium,
            boxShadow: isMe
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4.0.r,
                      offset: Offset(0, 2.0.h),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isMe
                        ? Colors.white
                        : (isDark ? AppColors.textLight : AppColors.textDark),
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(child: AppSpacing.h4),
              Text(
                _formatChatTime(timestamp),
                style: AppTextStyles.caption.copyWith(
                  color: isMe
                      ? AppColors.whitePlaceholder
                      : (isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight),
                  fontSize: 10.0.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
