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

            return MessageBubble(
              message: data['message'] as String? ?? '',
              timestamp: serverTimestamp,
              isMe: isMe,
              isDark: isDark
            );
          },
        );
      },
    );
  }
}
