import 'package:latlong2/latlong.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationHelper {
  static Future<void> openNavigationApp(LatLng point) async {
    final urls = [
      // Google navigation URL
      'google.navigation:q=${point.latitude},${point.longitude}&mode=d',
      'comgooglemaps://?saddr=&daddr=${point.latitude},${point.longitude}&directionsmode=driving',
      'geo:${point.latitude},${point.longitude}?z=15&q=${point.latitude},${point.longitude}',
      'https://maps.google.com/?saddr=&daddr=${point.latitude},${point.longitude}&dirflg=d',
      // Apple navigation URL
      'https://maps.apple.com/?saddr=&daddr=${point.latitude},${point.longitude}&dirflg=d',
    ];

    for (final urlString in urls) {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
        break;
      }
      Sentry.captureMessage('Cannot launch URL: $urlString');
    }
  }
}
