import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/message_bubble.dart';

import '../../../../core/constants/app_styles.dart';

class MessageListSection extends StatelessWidget {
  final String chatRoomId;
  final String currentUserId;
  final bool isDark;

  const MessageListSection({
    super.key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.isDark,
  });

  Widget _buildTimeDivider(Timestamp timestamp, bool isDark) {
    final DateTime dateTime = timestamp.toDate().toLocal();
    final DateTime now = DateTime.now();
    String formattedTime = "";

    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (dateTime.day == now.day - 1 && dateTime.month == now.month && dateTime.year == now.year) {
      formattedTime = "Hôm qua ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      formattedTime = "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          formattedTime,
          style: TextStyle(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasError) return const Center(child: Text("Đã xảy ra lỗi tải tin nhắn."));
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          itemBuilder: (context, index){
            final data = docs[index].data() as Map<String, dynamic>;
            final bool isMe = data['senderId'] == currentUserId;
            final Timestamp? serverTimestamp = data['timestamp'] as Timestamp?;

            bool showTimeDivider = false;
            if (index == docs.length - 1) {
              showTimeDivider = true;
            } else {
              final nextData = docs[index + 1].data() as Map<String, dynamic>;
              final Timestamp? nextTimestamp = nextData['timestamp'] as Timestamp?;
              if (serverTimestamp != null && nextTimestamp != null) {
                final diff = serverTimestamp.toDate().difference(nextTimestamp.toDate()).inMinutes.abs();
                if (diff >= 10) {
                  showTimeDivider = true;
                }
              }
            }

            final bubble = MessageBubble(
                message: data['message'] as String? ?? '',
                timestamp: serverTimestamp,
                isMe: isMe,
                isDark: isDark
            );

            if (showTimeDivider && serverTimestamp != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTimeDivider(serverTimestamp, isDark),
                  bubble,
                ],
              );
            }
            return bubble;
          },
        );
      },
    );
  }
}
