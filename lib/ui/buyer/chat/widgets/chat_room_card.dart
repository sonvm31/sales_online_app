import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/ui/buyer/chat/chat_screen.dart';

class ChatRoomCard extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final String roomId;
  final String currentUserId;
  final String currentUserName;
  final bool isDark;

  const ChatRoomCard({
    super.key,
    required this.roomData,
    required this.roomId,
    required this.currentUserId,
    required this.currentUserName,
    required this.isDark,
  });

  String _formatFirebaseTimeStamp(Timestamp? timestamp) {
    if (timestamp == null) return "Vừa xong";
    final DateTime dateTime = timestamp.toDate().toLocal();
    final DateTime now = DateTime.now();

    if (dateTime.day == now.day && dateTime.month == now.month &&
        dateTime.year == now.year) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.day == now.day - 1 && dateTime.month == now.month &&
        dateTime.year == now.year) {
      return "Hôm qua";
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> members = roomData['members'] as List<dynamic>? ?? [];
    final bool isSeller = currentUserId == roomData['shopId']?.toString();

    final String receiverId = isSeller
        ? members.firstWhere((m) => m.toString() != currentUserId, orElse: () => "").toString()
        : roomData['shopId']?.toString() ?? roomId.replaceAll(currentUserId, "").replaceAll("_", "");

    final String receiverName = isSeller
        ? roomData['senderName'] as String? ?? "Khách hàng"
        : roomData['shopName'] as String? ?? "Cửa hàng";

    final String rawLastMessage = roomData['lastMessage'] as String? ?? "";
    final String lastSenderId = roomData['lastSenderId'] as String? ?? "";
    final String lastMessage = rawLastMessage.isNotEmpty
        ? (lastSenderId == currentUserId ? "Bạn: $rawLastMessage" : rawLastMessage)
        : "Chưa có tin nhắn";
    final Timestamp? lastTimestamp = roomData['lastTimestamp'] as Timestamp?;

    final bool hasUnread = (lastSenderId != currentUserId) &&
        (roomData['hasUnread'] as bool? ?? false);
    final textMutedColor = isDark ? AppColors.textMutedDark : AppColors
        .textMutedLight;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.large
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: Stack(
          children: [
            Container(
              width: 48.0.w,
              height: 48.0.h,
              decoration: const BoxDecoration(
                  color: Color(0xFFEDF2F7),
                  shape: BoxShape.circle
              ),
              child: Icon(Icons.storefront_rounded, color: AppColors.primary,
                  size: 24.0.w),
            ),
            if(hasUnread)
              Positioned(
                top: 2.0.h,
                right: 2.0.w,
                child: Container(
                  width: AppSpacing.md,
                  height: AppSpacing.md,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark ? AppColors.surfaceDark : AppColors
                            .surfaceLight, width: 2),
                  ),
                ),
              )
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                receiverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: hasUnread ? FontWeight.w800 : FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textDark
                ),
              ),
            ),
            Text(
              _formatFirebaseTimeStamp(lastTimestamp),
              style: AppTextStyles.caption.copyWith(
                  color: hasUnread ? AppColors.primary : textMutedColor,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
                color: hasUnread ? (isDark ? AppColors.textLight : AppColors
                    .textDark) : textMutedColor,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal
            ),
          ),
        ),
        onTap: () async {
          if (hasUnread) {
            FirebaseFirestore.instance.collection('chats').doc(roomId).update({
              'hasUnread': false,
            });
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverId: receiverId,
                receiverName: receiverName,
                currentUserId: currentUserId,
                currentUserName: currentUserName,
              ),
            ),
          );
        },
      ),
    );
  }
}
