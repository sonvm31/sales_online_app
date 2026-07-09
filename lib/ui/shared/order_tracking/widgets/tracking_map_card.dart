import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_card.dart';
import 'package:sales_online_app/ui/shared/order_tracking/widgets/tracking_map_marker.dart';

class TrackingMapCard extends StatelessWidget {
  final OrderModel order;
  final List<LatLng> routePoints;
  final bool isRouteLoading;
  final LatLng? shopLocation;
  final LatLng? buyerLocation;

  const TrackingMapCard({
    super.key,
    required this.order,
    required this.routePoints,
    required this.isRouteLoading,
    required this.shopLocation,
    required this.buyerLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    if (shopLocation == null || buyerLocation == null) {
      return TrackingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.orderTrackingMapTitle,
              style: AppTextStyles.headingMedium.copyWith(color: textColor),
            ),
            AppSpacing.h8,
            Text(
              AppStrings.orderTrackingMissingLocation,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      );
    }

    final center = _mapCenter(shopLocation!, buyerLocation!);
    final points = routePoints.isEmpty
        ? <LatLng>[shopLocation!, buyerLocation!]
        : routePoints;

    return TrackingCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.orderTrackingMapTitle,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
                if (isRouteLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              bottom: AppRadius.large.bottomLeft,
            ),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 12.5),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sales_online.sales_online_app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        color: AppColors.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: shopLocation!,
                        width: 46,
                        height: 46,
                        child: const TrackingMapMarker(
                          icon: Icons.storefront_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      Marker(
                        point: buyerLocation!,
                        width: 46,
                        height: 46,
                        child: const TrackingMapMarker(
                          icon: Icons.location_on_outlined,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _mapCenter(LatLng shop, LatLng buyer) {
    final lat = (shop.latitude + buyer.latitude) / 2;
    final lng = (shop.longitude + buyer.longitude) / 2;

    if (lat.isFinite && lng.isFinite) {
      return LatLng(lat, lng);
    }

    return shop;
  }
}
