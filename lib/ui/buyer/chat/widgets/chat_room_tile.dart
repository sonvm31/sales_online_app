import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class ChatRoomTile extends StatelessWidget {
  final Map<String, dynamic> room;
  final VoidCallback onTap;

  const ChatRoomTile({
    super.key,
    required this.room,
    required this.onTap,
  });

  String _formatTime(dynamic time) {
    if (time == null) return '';
    DateTime dateTime;
    if (time is Timestamp) {
      dateTime = time.toDate();
    } else if (time is DateTime) {
      dateTime = time;
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    } else if (difference.inDays == 1) {
      return "Hôm qua";
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final tileColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final String shopName = room['shopName'] ?? 'Cửa hàng';
    final String lastMessage = room['lastMessage'] ?? '';
    final String avatarUrl = room['shopAvatarUrl'] ?? '';
    final int unreadCount = room['unreadCount'] ?? 0;
    final dynamic lastMessageTime = room['lastMessageTime'];

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: AppRadius.large,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade50,
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.storefront_rounded, size: 28, color: Colors.blue)
                  : ClipOval(
                child: Image.network(
                  avatarUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.storefront_rounded,
                    size: 28,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Text(
              _formatTime(lastMessageTime),
              style: AppTextStyles.caption.copyWith(
                color: mutedColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: unreadCount > 0 ? textColor : mutedColor,
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
