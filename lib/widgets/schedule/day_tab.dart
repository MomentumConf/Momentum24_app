import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayTab extends StatelessWidget {
  final DateTime day;
  final Color color;
  final double deviceWidth;
  final int daysCount;

  const DayTab({
    super.key,
    required this.day,
    required this.color,
    required this.deviceWidth,
    required this.daysCount,
  });

  @override
  Widget build(BuildContext context) {
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
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            dayOfMonth,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
