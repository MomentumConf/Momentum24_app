import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/notice.dart';
import '../services/data_provider_service.dart';
import '../widgets/momentum_appbar.dart';

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

    return Scaffold(
      appBar: MomentumAppBar(),
      body: RefreshIndicator(
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
                children: notifications.asMap().entries.map((entry) {
                  final notification = entry.value;
                  final index = entry.key;
                  return TimelineTile(
                    alignment: TimelineAlign.start,
                    isFirst: index == 0,
                    isLast: index == notifications.length - 1,
                    indicatorStyle: IndicatorStyle(
                        width: 40,
                        indicatorXY: 0,
                        color: Theme.of(context).primaryColor,
                        iconStyle: IconStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          iconData: Icons.notifications_outlined,
                        )),
                    beforeLineStyle: LineStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        thickness: 2),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                                textAlign: TextAlign.end,
                                textWidthBasis: TextWidthBasis.parent,
                              ),
                            ],
                          ),
                          Text(notification.title.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Expanded(
                              child: MarkdownBody(
                            data: notification.description,
                            onTapLink: (text, href, title) {
                              launchUrl(Uri.parse(href!));
                            },
                          )),
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
      ),
    );
  }
}
