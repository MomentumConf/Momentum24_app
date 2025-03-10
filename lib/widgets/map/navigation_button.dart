import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationButton extends StatelessWidget {
  final LatLng coordinates;

  const NavigationButton({
    super.key,
    required this.coordinates,
  });

  Future<void> _openNavigationApp() async {
    final urls = [
      // Google navigation URL
      'google.navigation:q=${coordinates.latitude},${coordinates.longitude}&mode=d',
      'comgooglemaps://?saddr=&daddr=${coordinates.latitude},${coordinates.longitude}&directionsmode=driving',
      'geo:${coordinates.latitude},${coordinates.longitude}?z=15&q=${coordinates.latitude},${coordinates.longitude}',
      'https://maps.google.com/?saddr=&daddr=${coordinates.latitude},${coordinates.longitude}&dirflg=d',
      // Apple navigation URL
      'https://maps.apple.com/?saddr=&daddr=${coordinates.latitude},${coordinates.longitude}&dirflg=d',
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

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.navigation),
      label: Text(AppLocalizations.of(context)!.navigateTo),
      onPressed: _openNavigationApp,
    );
  }
}
