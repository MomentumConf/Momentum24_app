import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../pages/information/speaker_details_screen.dart';
import '../../widgets/pill_button.dart';

class SpeakersList extends StatelessWidget {
  final Event event;
  final bool hasLightBackground;

  const SpeakersList({
    super.key,
    required this.event,
    required this.hasLightBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var speaker in event.speakers)
          PillButton(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) =>
                      SpeakerDetailsScreen(speakerId: speaker.id),
                ),
              );
            },
            child: Row(children: [
              CircleAvatar(
                backgroundImage:
                    FastCachedImageProvider("${speaker.imageUrl}?w=50&h=50"),
                radius: 12.5,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                speaker.name,
                maxLines: 1,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              )
            ]),
          )
      ],
    );
  }
}
