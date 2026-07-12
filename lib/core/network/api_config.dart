class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://onlinesales-api.onrender.com/api';
  static const String osrmRouteBaseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  static const Duration connectTimeout = Duration(minutes: 1);
  static const Duration receiveTimeout = Duration(minutes: 1);
  static const Duration routeTimeout = Duration(seconds: 8);
}
