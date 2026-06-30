import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales_online_app/data/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    late Dio dio;
    late RequestOptions capturedRequest;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            handler.resolve(
              Response<List<dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 1,
                    'title': 'Thông báo cũ',
                    'body': 'Nội dung',
                    'target': 'ALL',
                    'sendType': 'NOW',
                    'scheduledTime': null,
                    'status': 'SENT',
                    'createdAt': '2026-06-22T10:00:00',
                  },
                  {
                    'id': 2,
                    'title': 'Thông báo mới',
                    'body': 'Nội dung mới',
                    'target': 'BUYERS',
                    'sendType': 'SCHEDULE',
                    'scheduledTime': '2026-06-24T12:00:00',
                    'status': 'PENDING',
                    'createdAt': '2026-06-23T10:00:00',
                  },
                ],
              ),
            );
          },
        ),
      );
    });

    test(
      'fetchAllNotifications calls all endpoint and parses schema',
      () async {
        final service = NotificationService(dio: dio);

        final notifications = await service.fetchAllNotifications();

        expect(capturedRequest.path, '/notifications');
        expect(capturedRequest.queryParameters, isEmpty);
        expect(notifications.map((item) => item.id), [2, 1]);
        expect(notifications.first.scheduledTime, isNotNull);
        expect(notifications.last.scheduledTime, isNull);
      },
    );

    test('fetchMobileNotifications sends normalized role', () async {
      final service = NotificationService(dio: dio);

      await service.fetchMobileNotifications(role: 'sellers');

      expect(capturedRequest.path, '/notifications/mobile');
      expect(capturedRequest.queryParameters, {'role': 'SELLER'});
    });
  });
}
