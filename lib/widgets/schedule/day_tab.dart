import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayTab extends StatelessWidget {
  final DateTime day;
  final int daysCount;
  final bool isHighlighted;

  const DayTab({
    super.key,
    required this.day,
    required this.daysCount,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    final colorHighlighted = Theme.of(context).colorScheme.onSurface;
    final deviceWidth = MediaQuery.of(context).size.width;

    final weekday =
        DateFormat('EEE').format(day).replaceAll(RegExp(r'\.$'), '');
    final dayOfMonth = DateFormat('d').format(day);

    return SizedBox(
      width: deviceWidth / daysCount,
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ((deviceWidth > 365 || weekday.length == 2)
                    ? weekday
                    : weekday[0] + weekday[2])
                .toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isHighlighted? colorHighlighted : color,
              fontSize: 12,
            ),
          ),
          Text(
            dayOfMonth,
            style: TextStyle(
              fontSize: 16,
              color: isHighlighted? colorHighlighted : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
