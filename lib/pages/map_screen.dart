import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:momentum24_app/models/map.dart';
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/widgets/map/map_view.dart';
import 'package:momentum24_app/widgets/map/marker_list_item.dart';
import 'package:momentum24_app/widgets/map/navigation_button.dart';
import 'package:momentum24_app/widgets/map/marker_icon_helper.dart';
import 'package:momentum24_app/widgets/map/navigation_helper.dart';

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
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    final onSurfaceColor =
        isDarkTheme ? theme.colorScheme.onSurface : theme.colorScheme.surface;
    for (final (index, marker) in markers.indexed) {
      newMarkers.add(
        map.Marker(
          point: marker.coordinates,
          child: GestureDetector(
            onTap: () {
              _pageController.jumpToPage(index);
            },
            child: Icon(
              MarkerIconHelper.getMarkerIcon(marker.icon),
              color: currentMarkerIndex == index
                  ? primaryColor
                  : (isDarkTheme ? onSurfaceColor : onPrimaryColor),
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
                      MapView(
                        mapController: _mapController,
                        center: center,
                        zoom: zoom,
                        markers: _markers.toList(),
                        isDarkTheme: isDarkTheme,
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: NavigationButton(
                          onPressed: () {
                            NavigationHelper.openNavigationApp(
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
                          final isSelected = currentMarkerIndex == index;

                          return MarkerListItem(
                            marker: marker,
                            isSelected: isSelected,
                            onTap: () {
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut);
                            },
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
