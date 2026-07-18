import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/buyer/chat/widgets/chat_room_card.dart';
import 'package:sales_online_app/data/services/shop_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = true;
  String _resolvedUserId = "unknown_user";
  String _resolvedUserName = "Người dùng";

  @override
  void initState() {
    super.initState();
    _resolveUserChatInfo();
  }

  Future<void> _resolveUserChatInfo() async {
    final session = authController.session;
    if (session == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final userId = session.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _resolvedUserId = "unknown_user";
          _isLoading = false;
        });
      }
      return;
    }

    if (session.role.toUpperCase() == 'SELLER') {
      try {
        final shop = await ShopService().fetchShopByOwner(userId);
        if (mounted) {
          setState(() {
            _resolvedUserId = shop.id.toString();
            _resolvedUserName = shop.name;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching shop info for chat: $e");
        if (mounted) {
          setState(() {
            _resolvedUserId = userId.toString();
            _resolvedUserName = session.fullName ?? "Người bán";
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _resolvedUserId = userId.toString();
          _resolvedUserName = session.fullName ?? "Khách hàng";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('members', arrayContains: _resolvedUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Đã xảy ra lỗi tải danh sách."));
          }
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
                currentUserId: _resolvedUserId,
                currentUserName: _resolvedUserName,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}
