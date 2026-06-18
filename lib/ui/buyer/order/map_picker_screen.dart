import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final LatLng _initCenter = const LatLng(10.8412, 106.8099);
  late LatLng _currCenter;
  String? _addressText;

  List<dynamic> _searchResult = [];
  bool _isSearching = false;
  bool _isReverseLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currCenter = _initCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getReverseGeocode(_initCenter);
    });
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
    });
    try {
      final dio = Dio();
      List<dynamic> data = await _fetchNominatimSearch(dio, query);
      if (data.isEmpty && query.contains('/')) {
        final parts = query.split(' ');
        final cleanParts = parts
            .where((p) => !p.contains('/') && !RegExp(r'^\d+$').hasMatch(p))
            .join(' ');

        if (cleanParts.trim().isNotEmpty) {
          data = await _fetchNominatimSearch(dio, cleanParts);
        }
      }

      setState(() {
        _searchResult = data;
      });
    } catch (e) {
      debugPrint("Lỗi map: $e");
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<List<dynamic>> _fetchNominatimSearch(Dio dio, String q) async {
    final response = await dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': q,
        'format': 'json',
        'limit': 5,
        'accept-language': 'vi',
        'countrycodes': 'vn',
      },
      options: Options(
        headers: {'User-Agent': 'SalesOnlineApp/1.0 (fuongduy@gmail.com)'},
      ),
    );
    return response.data ?? [];
  }

  Future<void> _getReverseGeocode(LatLng location) async {
    setState(() {
      _isReverseLoading = true;
    });
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'format': 'json',
          'accept-language': 'vi',
        },
        options: Options(
          headers: {'User-Agent': 'SalesOnlineApp/1.0 (fuongduy@gmail.com)'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _addressText =
              response.data['display_name'] ?? "Vị trí không xác định";
        });
      }
    } catch (e) {
      debugPrint("Lỗi reverse geocoding: $e");
    } finally {
      setState(() {
        _isReverseLoading = false;
      });
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;

    _currCenter = camera.center;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _getReverseGeocode(_currCenter);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Chọn vị trí giao hàng"),
          backgroundColor: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          elevation: 0,
          titleTextStyle: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
          iconTheme: IconThemeData(
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initCenter,
                initialZoom: 16.0,
                onPositionChanged: _onMapPositionChanged,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sales_online_app',
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 48,
                  color: Colors.red,
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: AppRadius.large,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.search_outlined),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _searchAddress,
                            decoration: InputDecoration(
                              hintText: "Tìm địa chỉ...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ),
                        ),
                        _isSearching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () =>
                                    _searchAddress(_searchController.text),
                              ),
                      ],
                    ),
                  ),
                  if (_searchResult.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: AppRadius.large,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResult.length,
                        itemBuilder: (context, index) {
                          final item = _searchResult[index];
                          return ListTile(
                            title: Text(
                              item['display_name'] ?? "",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                              ),
                            ),
                            onTap: () {
                              final lat = double.parse(item['lat']);
                              final lng = double.parse(item['lon']);
                              _mapController.move(LatLng(lat, lng), 16.0);
                              setState(() {
                                _currCenter = LatLng(lat, lng);
                                _addressText = item['display_name'];
                                _searchResult.clear();
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.only(
                    topLeft: AppRadius.xLarge.topLeft,
                    topRight: AppRadius.xLarge.topRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isReverseLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            _addressText ?? "Đang xác định vị trí...",
                            style: AppTextStyles.headingMedium.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                    SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, {
                        'address': _addressText,
                        'lat': _currCenter.latitude,
                        'lng': _currCenter.longitude,
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.medium,
                        ),
                      ),
                      child: Text(
                        "Xác nhận địa chỉ",
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
