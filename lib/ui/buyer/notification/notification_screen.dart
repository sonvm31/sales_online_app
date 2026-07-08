import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/app_notification.dart';
import 'package:sales_online_app/logic/notification/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController controller;

  const NotificationScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: AppTextStyles.headingMedium.copyWith(color: textColor),
        ),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              if (controller.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: const Text('Đọc tất cả'),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null &&
              controller.notifications.isEmpty) {
            return _ErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadNotifications,
            );
          }

          if (controller.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.loadNotifications,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 520, child: _EmptyNotificationState()),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            color: AppColors.primary,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: controller.notifications.length,
              separatorBuilder: (_, _) => AppSpacing.h8,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => controller.markAsRead(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Material(
      color: notification.isRead
          ? surfaceColor
          : AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.07),
      borderRadius: AppRadius.large,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.large,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.large,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.medium,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              AppSpacing.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: textColor,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          AppSpacing.w8,
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      AppSpacing.h4,
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: mutedColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                    AppSpacing.h8,
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTextStyles.caption.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            AppSpacing.h16,
            Text(message, textAlign: TextAlign.center),
            AppSpacing.h16,
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 58, color: mutedColor),
            AppSpacing.h16,
            const Text('Chưa có thông báo'),
            AppSpacing.h8,
            Text(
              'Thông báo mới từ hệ thống sẽ xuất hiện tại đây.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime createdAt) {
  final localTime = createdAt.toLocal();
  final difference = DateTime.now().difference(localTime);
  if (!difference.isNegative) {
    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
  }
  final day = localTime.day.toString().padLeft(2, '0');
  final month = localTime.month.toString().padLeft(2, '0');
  return '$day/$month/${localTime.year}';
}
