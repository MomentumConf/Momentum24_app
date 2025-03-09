import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/notice.dart';

class NotificationTimelineTile extends StatelessWidget {
  final Notice notification;
  final bool isFirst;
  final bool isLast;

  const NotificationTimelineTile({
    super.key,
    required this.notification,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 40,
        indicatorXY: 0,
        color: Theme.of(context).primaryColor,
        iconStyle: IconStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          iconData: Icons.notifications_outlined,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        thickness: 2,
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  DateFormat('HH:mm // EEEE')
                      .format(notification.date.toLocal()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                  textWidthBasis: TextWidthBasis.parent,
                ),
              ],
            ),
            Text(
              notification.title.toUpperCase(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: MarkdownBody(
                data: notification.description.isEmpty
                    ? " "
                    : notification.description,
                onTapLink: (text, href, title) {
                  launchUrl(Uri.parse(href!));
                },
              ),
            ),
          ],
        ),
      ),
      hasIndicator: true,
    );
  }
}
