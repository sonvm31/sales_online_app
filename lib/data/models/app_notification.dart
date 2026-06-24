class AppNotification {
  final int id;
  final String title;
  final String body;
  final String target;
  final String sendType;
  final DateTime? scheduledTime;
  final String status;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.sendType,
    required this.scheduledTime,
    required this.status,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _parseId(json['id']),
      title: json['title']?.toString() ?? 'Thông báo',
      body: json['body']?.toString() ?? '',
      target: json['target']?.toString() ?? 'ALL',
      sendType: json['sendType']?.toString() ?? 'NOW',
      scheduledTime: _parseDateTime(json['scheduledTime']),
      status: json['status']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      target: target,
      sendType: sendType,
      scheduledTime: scheduledTime,
      status: status,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static int _parseId(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
