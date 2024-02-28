import 'package:flutter/foundation.dart';

class TextScaleManager with ChangeNotifier {
  double _scaleFactor = 1.3;

  double get scaleFactor => _scaleFactor;

  set scaleFactor(double newValue) {
    _scaleFactor = newValue;
    notifyListeners();
  }
}

final textScaleManager = TextScaleManager();
