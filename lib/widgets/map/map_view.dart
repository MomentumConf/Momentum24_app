import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final map.MapController mapController;
  final LatLng center;
  final double zoom;
  final List<map.Marker> markers;

  const MapView({
    super.key,
    required this.mapController,
    required this.center,
    required this.zoom,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return map.FlutterMap(
      mapController: mapController,
      options: map.MapOptions(
        initialCenter: center,
        initialZoom: zoom,
      ),
      children: [
        map.TileLayer(
            tileProvider: map.NetworkTileProvider(),
            urlTemplate: isDarkTheme
                ? "https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png"
                : "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"),
        map.MarkerLayer(markers: markers),
      ],
    );
  }
}
