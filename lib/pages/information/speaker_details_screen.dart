import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:string_unescape/string_unescape.dart';

import '../../models/speaker.dart';
import '../../services/data_provider_service.dart';
import '../../widgets/snapping_handler.dart';

class SpeakerDetailsScreen extends StatelessWidget {
  final String speakerId;

  final DataProviderService _dataProviderService =
      GetIt.I<DataProviderService>();

  SpeakerDetailsScreen({super.key, required this.speakerId});

  List<dynamic> getEventsWithSpeaker(
      List<dynamic> events, String currentSpeaker) {
    List<dynamic> eventsWithSpeaker = [];

    for (var event in events) {
      if (event['speakers'] != null &&
          List.from(event['speakers'])
              .where((speaker) =>
                  speaker != null && speaker['_ref'] == currentSpeaker)
              .isNotEmpty) {
        eventsWithSpeaker.add(event);
        continue;
      }

      if (event['subevents'] != null && event['subevents'].isNotEmpty) {
        for (var subevent in event['subevents']) {
          if (subevent['speakers'] != null &&
              List.from(subevent['speakers'])
                  .where((speaker) =>
                      speaker != null && speaker['_ref'] == currentSpeaker)
                  .isNotEmpty) {
            var subeventCopy = Map.from(subevent);
            subeventCopy['title'] =
                "${event['title']}: ${subeventCopy['title']}";
            subeventCopy['start'] = event['start'];
            eventsWithSpeaker.add(subeventCopy);
          }
        }
      }
    }

    eventsWithSpeaker.sort((a, b) =>
        DateTime.parse(a['start']).compareTo(DateTime.parse(b['start'])));

    return eventsWithSpeaker;
  }

  String getEventsMarkdown(
      {required List<dynamic> events,
      required String currentSpeaker,
      required String sessionsHeading}) {
    String eventsMarkdown = "  \n  \n  \n## $sessionsHeading\n";
    for (var event in getEventsWithSpeaker(events, currentSpeaker)) {
      eventsMarkdown +=
          "**${event['title']}**  \n${DateFormat('EEEE, HH:mm').format(DateTime.parse(event['start']!))} - ${event['location']}\n\n";
    }
    return unescape(eventsMarkdown);
  }

  Future<Speaker> getSpeaker() async {
    List<Speaker> speakers;
    try {
      speakers = await _dataProviderService.getSpeakers();
    } catch (e) {
      speakers = [];
    }
    return speakers.firstWhere((speaker) => speaker.id == speakerId);
  }

  @override
  Widget build(BuildContext context) {
    final textStyleWhiteColor = TextStyle(
      color: Theme.of(context).colorScheme.onSecondary,
    );
    return FutureBuilder(
      future: getSpeaker(),
      builder: (BuildContext context, AsyncSnapshot<Speaker> speaker) {
        if (speaker.connectionState != ConnectionState.done ||
            !speaker.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(speaker.data!.name),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: "${speaker.data!.imageUrl}?auto=format&q=100",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.memory(
                      Uri.parse(speaker.data!.imageLqip).data!.contentAsBytes(),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.05,
                  maxChildSize: 1.0,
                  snap: true,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: <Widget>[
                          const Center(child: SnappingHandler()),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MarkdownBody(
                                styleSheet: MarkdownStyleSheet.fromTheme(
                                        Theme.of(context))
                                    .copyWith(
                                        p: textStyleWhiteColor,
                                        h2: textStyleWhiteColor,
                                        strong: textStyleWhiteColor),
                                data: speaker.data!.description +
                                    getEventsMarkdown(
                                        events: speaker.data!.events,
                                        currentSpeaker: speaker.data!.id,
                                        sessionsHeading:
                                            AppLocalizations.of(context)!
                                                .sessions)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
