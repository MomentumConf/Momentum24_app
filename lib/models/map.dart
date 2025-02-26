import 'package:latlong2/latlong.dart';

class MapData {
  final LatLng center;
  final List<Marker> markers;
  final double zoom;

  MapData({
    required this.center,
    required this.markers,
    required this.zoom,
  });

  factory MapData.fromJson(Map<String, dynamic> json) {
    return MapData(
      center: LatLng(json['center']['latitude'], json['center']['longitude']),
      markers: (json['markers'] as List)
          .map((marker) => Marker.fromJson(marker))
          .toList(),
      zoom: (json['zoom'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center': {
        'latitude': center.latitude,
        'longitude': center.longitude,
      },
      'markers': markers.map((marker) => marker.toJson()).toList(),
      'zoom': zoom,
    };
  }
}

class Marker {
  final String address;
  final LatLng coordinates;
  final String icon;
  final String title;

  Marker({
    required this.address,
    required this.coordinates,
    required this.icon,
    required this.title,
  });

  factory Marker.fromJson(Map<String, dynamic> json) {
    return Marker(
      address: json['address'] ?? "",
      coordinates: LatLng(
          json['coordinates']['latitude'], json['coordinates']['longitude']),
      icon: json['icon'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'icon': icon,
      'title': title,
    };
  }
}
