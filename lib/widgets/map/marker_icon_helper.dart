import 'package:flutter/material.dart';

class MarkerIconHelper {
  static IconData getMarkerIcon(String? iconName) {
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
      case 'pets':
        return Icons.pets;
      case 'pin':
      default:
        return Icons.pin_drop_outlined;
    }
  }
}
