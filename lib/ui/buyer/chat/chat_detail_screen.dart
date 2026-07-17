import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/services/chat_firestore_service.dart';
import 'package:sales_online_app/logic/auth/auth_controller.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/message_bubble.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/message_input.dart';

class ChatDetailScreen extends StatefulWidget {
  final AuthController authController;
  final String roomId;
  final int shopId;
  final String shopName;
  final String shopAvatarUrl;

  const ChatDetailScreen({
    super.key,
    required this.authController,
    required this.roomId,
    required this.shopId,
    required this.shopName,
    required this.shopAvatarUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatFirestoreService _chatService = ChatFirestoreService();

  @override
  void initState() {
    super.initState();
    _chatService.markRoomAsRead(widget.roomId);
  }

  void _sendMessage(String content) {
    final session = widget.authController.session;
    if (session == null) return;

    _chatService.sendMessage(
      roomId: widget.roomId,
      buyerUid: session.firebaseUid,
      buyerName: session.fullName ?? session.email,
      shopId: widget.shopId,
      shopName: widget.shopName,
      shopAvatarUrl: widget.shopAvatarUrl,
      senderId: session.firebaseUid,
      senderName: session.fullName ?? session.email,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final session = widget.authController.session;
    final String myUid = session?.firebaseUid ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade50,
              child: widget.shopAvatarUrl.isEmpty
                  ? const Icon(Icons.storefront_rounded, size: 20, color: Colors.blue)
                  : ClipOval(
                child: Image.network(
                  widget.shopAvatarUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shopName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user_presence')
                        .doc(widget.shopId.toString())
                        .snapshots(),
                    builder: (context, snapshot) {
                      bool isOnline = false;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        isOnline = data?['isOnline'] as bool? ?? false;
                      }
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? "Đang hoạt động" : "Ngoại tuyến",
                            style: AppTextStyles.caption.copyWith(
                              color: mutedColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getMessages(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Đã xảy ra lỗi khi tải tin nhắn",
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "Hãy gửi tin nhắn đầu tiên để bắt đầu trò chuyện!",
                      style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message['senderId'] == myUid;
                    return MessageBubble(
                      message: message['content'] as String? ?? '',
                      timestamp: message['timestamp'] as Timestamp?,
                      isMe: isMe,
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
