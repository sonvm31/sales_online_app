import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:sales_online_app/core/network/api_config.dart';

class OrderRouteService {
  final Dio _dio;

  OrderRouteService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<LatLng>> fetchRoute({
    required LatLng shopLocation,
    required LatLng buyerLocation,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConfig.osrmRouteBaseUrl}/'
        '${shopLocation.longitude},${shopLocation.latitude};'
        '${buyerLocation.longitude},${buyerLocation.latitude}',
        queryParameters: const <String, dynamic>{
          'overview': 'full',
          'geometries': 'geojson',
        },
        options: Options(
          sendTimeout: ApiConfig.routeTimeout,
          receiveTimeout: ApiConfig.routeTimeout,
        ),
      );

      final coordinates = _extractCoordinates(response.data);
      final points = <LatLng>[];

      if (coordinates is List) {
        for (final coordinate in coordinates) {
          if (coordinate is List && coordinate.length >= 2) {
            final lng = (coordinate[0] as num?)?.toDouble();
            final lat = (coordinate[1] as num?)?.toDouble();
            if (_isValidLocation(lat, lng)) {
              points.add(LatLng(lat!, lng!));
            }
          }
        }
      }

      return points.isEmpty ? <LatLng>[shopLocation, buyerLocation] : points;
    } catch (_) {
      return <LatLng>[shopLocation, buyerLocation];
    }
  }

  dynamic _extractCoordinates(Map<String, dynamic>? data) {
    final routes = data?['routes'];
    if (routes is! List || routes.isEmpty) return null;

    final firstRoute = routes.first;
    if (firstRoute is! Map) return null;

    final geometry = firstRoute['geometry'];
    if (geometry is! Map) return null;

    return geometry['coordinates'];
  }

  bool _isValidLocation(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat.isFinite &&
        lng.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }
}
