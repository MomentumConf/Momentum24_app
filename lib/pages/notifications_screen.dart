import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/data_provider_service.dart';
import '../models/notice.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();

  List<Notice> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {
    final data = await _dataProviderService.setNotifier(
      (value) {
        updateNotifications(value as List<Notice>);
      },
    ).getNotifications();

    updateNotifications(data);
  }

  void updateNotifications(List<Notice> data) {
    setState(() {
      isLoading = false;
      notifications = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _dataProviderService.setNotifier(
          (value) {
            updateNotifications(value as List<Notice>);
          },
        ).getNotifications(forceNewData: true);
      },
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: notifications.asMap().entries.map((entry) {
                final notification = entry.value;
                final index = entry.key;
                return TimelineTile(
                  alignment: TimelineAlign.end,
                  lineXY: 1,
                  isFirst: index == 0,
                  isLast: index == notifications.length - 1,
                  indicatorStyle: IndicatorStyle(
                      width: 30,
                      color: Theme.of(context).primaryColor,
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: Icons.notifications,
                      )),
                  beforeLineStyle: LineStyle(
                      color: Theme.of(context).primaryColor, thickness: 2),
                  startChild: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${DateFormat('EEEE, HH:mm').format(notification.date)} (${timeago.format(notification.date, locale: 'pl')})",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              textAlign: TextAlign.end,
                              textWidthBasis: TextWidthBasis.parent,
                            ),
                          ],
                        ),
                        Text(notification.title.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Expanded(
                            child:
                                MarkdownBody(data: notification.description)),
                      ],
                    ),
                  ),
                  hasIndicator: true,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
