import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/chat_room_card.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId =
        authController.session?.userId?.toString() ?? "unknown_user";

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Tin nhắn",
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('members', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Đã xảy ra lỗi tải danh sách."));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final chatRooms = snapshot.data?.docs ?? [];

          if (chatRooms.isEmpty) {
            return Center(
              child: Text(
                "Bạn chưa có đoạn hội thoại nào.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            );
          }
          chatRooms.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final Timestamp? aTime = aData['lastTimestamp'] as Timestamp?;
            final Timestamp? bTime = bData['lastTimestamp'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              return ChatRoomCard(
                roomData: chatRooms[index].data() as Map<String, dynamic>,
                roomId: chatRooms[index].id,
                currentUserId: currentUserId,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}
