import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/chat_input_field.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/message_list_section.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String _currentUserId;
  late final String _currentUserName;
  late final String _chatRoomId;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        authController.session?.userId?.toString() ?? "unknown_user";
    _currentUserName = authController.session?.fullName ?? "Khách hàng";
    _chatRoomId = _getChatRoomId(_currentUserId, widget.receiverId);
  }

  String _getChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 20.0.w,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36.0.w,
              height: 36.0.h,
              decoration: const BoxDecoration(
                color: Color(0xFFEDF2F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: AppColors.primary,
                size: 18.0.w,
              ),
            ),
            AppSpacing.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.receiverName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6.0.w,
                        height: 6.0.h,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.w4,
                      Text(
                        "Đang online",
                        style: AppTextStyles.caption.copyWith(
                          color: textMutedColor,
                          fontSize: 11.0.sp,
                        ),
                      ),
                    ],
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
            child: MessageListSection(
              chatRoomId: _chatRoomId,
              currentUserId: _currentUserId,
              isDark: isDark,
            ),
          ),
          ChatInputField(
            chatRoomId: _chatRoomId,
            currentUserId: _currentUserId,
            currentUserName: _currentUserName,
            receiverId: widget.receiverId,
            receiverName: widget.receiverName,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
