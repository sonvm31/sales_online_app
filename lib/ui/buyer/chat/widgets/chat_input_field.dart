import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/main.dart';

class ChatInputField extends StatefulWidget{
  final String chatRoomId;
  final String currentUserId;
  final String currentUserName;
  final String receiverId;
  final String receiverName;
  final bool isDark;

  const ChatInputField({
    super.key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.currentUserName,
    required this.receiverId,
    required this.receiverName,
    required this.isDark
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>{
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if(text.isEmpty) return;

    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add({
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'receiverId': widget.receiverId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final bool isSeller = authController.session?.role == 'SELLER';
    final String shopId = isSeller ? widget.currentUserId : widget.receiverId;
    final String shopName = isSeller ? widget.currentUserName : widget.receiverName;
    final String buyerName = isSeller ? widget.receiverName : widget.currentUserName;

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId).set({
      'members': [widget.currentUserId, widget.receiverId],
      'lastMessage': text,
      'lastSenderId': widget.currentUserId,
      'shopId': shopId,
      'shopName': shopName,
      'senderName': buyerName,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'hasUnread': true,
    }, SetOptions(merge: true));
  }

  @override
  void dispose(){
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: AppSpacing.xxl,
                decoration: BoxDecoration(
                    color: widget.isDark ? Colors.black26 : const Color(0xFFF3F4F6),
                    borderRadius: AppRadius.xLarge
                ),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _messageController,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.isDark ? AppColors.textLight : AppColors.textDark
                  ),
                  decoration: InputDecoration(
                    hintText: "Nhắn tin cho shop...",
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md - 4.h),
                  ),
                ),
              ),
            ),
            SizedBox(child: AppSpacing.h16),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                  width: 44.0.w,
                  height: 44.0.h,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 18.0.w)
              ),
            )
          ],
        ),
      ),
    );
  }
}