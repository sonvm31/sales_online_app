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
    final senderBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.0.r),
      topRight: Radius.circular(16.0.r),
      bottomLeft: Radius.circular(16.0.r),
      bottomRight: Radius.circular(4.0.r),
    );

    final receiverBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.0.r),
      topRight: Radius.circular(16.0.r),
      bottomLeft: Radius.circular(4.0.r),
      bottomRight: Radius.circular(16.0.r),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0.h),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.0.w,
            vertical: 10.0.h,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFF5A5DF0), // Beautiful modern indigo gradient
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isMe
                ? null
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: isMe ? senderBorderRadius : receiverBorderRadius,
            boxShadow: isMe
                ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe
                      ? Colors.white
                      : (isDark ? AppColors.textLight : AppColors.textDark),
                  height: 1.4,
                  fontSize: 14.5.sp,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatChatTime(timestamp),
                style: AppTextStyles.caption.copyWith(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.65)
                      : (isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight),
                  fontSize: 9.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
