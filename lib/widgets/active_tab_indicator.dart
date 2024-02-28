import 'package:flutter/material.dart';

class ActiveTabIndicator extends Decoration {
  final BoxPainter _painter;

  ActiveTabIndicator({required Color color, required double radius})
      : _painter = _MyTabIndicatorPainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _MyTabIndicatorPainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _MyTabIndicatorPainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect =
        Offset(offset.dx, -7.5) & Size(configuration.size!.width, 60);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)), _paint);
  }
}
