import 'package:flutter/material.dart';
import '../../models/map.dart';
import 'marker_icon_helper.dart';

class MarkerListItem extends StatelessWidget {
  final Marker marker;
  final bool isSelected;
  final VoidCallback onTap;

  const MarkerListItem({
    super.key,
    required this.marker,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.primaryColor : theme.colorScheme.onSurface;
    final icon = MarkerIconHelper.getMarkerIcon(marker.icon);

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
        color: theme.colorScheme.surface,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        horizontalTitleGap: 8,
        dense: true,
        leading: Icon(
          icon,
          color: color,
          size: 20,
        ),
        title: Text(
          marker.title,
          style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          marker.address,
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
