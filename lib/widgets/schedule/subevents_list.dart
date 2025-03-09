import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../widgets/pill_button.dart';
import 'event_detail_modal.dart';

class SubeventsList extends StatelessWidget {
  final List<Event> subevents;

  const SubeventsList({
    super.key,
    required this.subevents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subevents
          .map((subevent) => PillButton(
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        subevent.title,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            height: 1.1,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                onTap: () =>
                    EventDetailModal.show(context, subevent, isSubevent: true),
              ))
          .toList(),
    );
  }
}
