import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:momentum24_app/models/notice.dart';
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/widgets/momentum_appbar.dart';
import 'package:momentum24_app/widgets/notification_timeline_tile.dart';

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

  Future<void> refreshNotifications() async {
    await _dataProviderService.setNotifier(
      (value) {
        updateNotifications(value as List<Notice>);
      },
    ).getNotifications(forceNewData: true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: const MomentumAppBar(),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: refreshNotifications,
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
                  return NotificationTimelineTile(
                    notification: notification,
                    isFirst: index == 0,
                    isLast: index == notifications.length - 1,
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
