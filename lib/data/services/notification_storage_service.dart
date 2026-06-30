import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorageService {
  static const String _readNotificationIdsKey = 'read_notification_ids';

  Future<Set<int>> readIds() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_readNotificationIdsKey) ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> markAsRead(int notificationId) async {
    final ids = await readIds();
    ids.add(notificationId);
    await _save(ids);
  }

  Future<void> markAllAsRead(Iterable<int> notificationIds) async {
    final ids = await readIds();
    ids.addAll(notificationIds);
    await _save(ids);
  }

  Future<void> _save(Set<int> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _readNotificationIdsKey,
      ids.map((id) => id.toString()).toList(),
    );
  }
}
