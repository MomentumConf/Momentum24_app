import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:momentum24_app/colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/map.dart';
import '../services/data_provider_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> implements TickerProvider {
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();

  final Set<map.Marker> _markers = {};
  final map.MapController _mapController = map.MapController();
  final PageController _pageController = PageController(viewportFraction: 0.6);

  int currentMarkerIndex = 0;
  bool isLoading = true;
  double zoom = 15.0;
  LatLng center = const LatLng(54.1795, 15.5685);
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    getMapData();
  }

  void buildMarkers() {
    var newMarkers = <map.Marker>{};
    for (final (index, marker) in markers.indexed) {
      newMarkers.add(
        map.Marker(
          point: marker.coordinates,
          child: GestureDetector(
            onTap: () {
              _pageController.jumpToPage(index);
            },
            child: Icon(
              getMarkerIcon(marker.icon),
              color: currentMarkerIndex == index ? primaryColor : textColor,
              size: currentMarkerIndex == index ? 40 : 30,
            ),
          ),
        ),
      );
    }
    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  void getMapData() async {
    final data =
        await _dataProviderService.setNotifier(updateMapData).getMapData();
    updateMapData(data);
  }

  void updateMapData(value) {
    setState(() {
      markers = (value as MapData).markers;
      center = value.center;
      zoom = value.zoom;
      isLoading = false;
    });
    buildMarkers();
  }

  IconData getMarkerIcon(String? iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'music':
        return Icons.music_note_sharp;
      case 'umbrella':
        return Icons.beach_access;
      case 'train':
        return Icons.directions_train_sharp;
      case 'bus':
        return Icons.directions_bus_sharp;
      case 'restaurant':
        return Icons.restaurant;
      case 'counter_1':
        return Icons.looks_one_outlined;
      case 'counter_2':
        return Icons.looks_two_outlined;
      case 'counter_3':
        return Icons.looks_3_outlined;
      case 'hotel':
        return Icons.hotel;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'pin':
      default:
        return Icons.pin_drop_outlined;
    }
  }

  Future<void> openNavigationApp(LatLng point) async {
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

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      map.FlutterMap(
                        mapController: _mapController,
                        options: map.MapOptions(
                          initialCenter: center,
                          initialZoom: zoom,
                        ),
                        children: [
                          map.TileLayer(
                              tileProvider: CancellableNetworkTileProvider(),
                              urlTemplate: isDarkTheme
                                  ? "https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png"
                                  : "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"),
                          map.MarkerLayer(markers: _markers.toList()),
                        ],
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.navigation),
                          label: Text(AppLocalizations.of(context)!.navigateTo),
                          onPressed: () {
                            openNavigationApp(
                                markers[currentMarkerIndex].coordinates);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: markers.length,
                        controller: _pageController,
                        onPageChanged: (value) {
                          setState(() {
                            currentMarkerIndex = value;
                          });
                          buildMarkers();

                          _animatedMapMove(
                            markers[value].coordinates,
                            zoom,
                          );
                        },
                        itemBuilder: (context, index) {
                          final marker = markers[index];
                          final color = currentMarkerIndex == index
                              ? theme.primaryColor
                              : theme.colorScheme.onPrimary;
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: color,
                                width: 2,
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 0.0),
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              horizontalTitleGap: 8,
                              dense: true,
                              leading: Icon(
                                getMarkerIcon(marker.icon),
                                color: color,
                                size: 20,
                              ),
                              title: Text(
                                marker.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.1, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                marker.address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  height: 1.1,
                                ),
                              ),
                              onTap: () {
                                _pageController.animateToPage(index,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut);
                              },
                            ),
                          );
                        })),
              ],
            ),
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
