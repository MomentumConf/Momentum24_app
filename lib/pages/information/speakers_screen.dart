import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:string_unescape/string_unescape.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/data_provider_service.dart';
import '../../models/speaker.dart';

class SpeakersScreen extends StatefulWidget {
  final String? speaker;
  const SpeakersScreen({super.key, this.speaker});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  late PageController _pageController;
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();
  int initialPageIndex = 0;
  bool isLoading = true;
  String title = "";

  List<Speaker> speakers = [];

  @override
  void initState() {
    super.initState();
    loadSpeakers();
  }

  void loadSpeakers() async {
    final apiData = await _dataProviderService.setNotifier((value) {
      setState(() {
        speakers = value as List<Speaker>;
        title = value[initialPageIndex].name;
      });
    }).getSpeakers();

    var initialSpeaker = 0;
    if (widget.speaker != null) {
      initialSpeaker = findRequestedSpeaker(apiData);
    }

    setState(() {
      initialPageIndex = initialSpeaker;
      speakers = apiData;
      title = apiData[initialSpeaker].name;
      isLoading = false;
    });

    _pageController =
        PageController(initialPage: initialSpeaker, viewportFraction: 0.93);
  }

  int findRequestedSpeaker(List<Speaker> speakers) {
    var speakerIndex =
        speakers.indexWhere((speaker) => speaker.id == widget.speaker);
    if (speakerIndex == -1) {
      return 0;
    }
    return speakerIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              title.isEmpty ? AppLocalizations.of(context)!.speakers : title)),
      body: isLoading || speakers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              onPageChanged: (value) => setState(() {
                title = speakers[value].name;
              }),
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: speakers.length,
              itemBuilder: (context, index) {
                var currentSpeaker = speakers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl:
                              "${currentSpeaker.imageUrl}?auto=format&q=100",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.memory(
                            Uri.parse(currentSpeaker.imageLqip)
                                .data!
                                .contentAsBytes(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      DraggableScrollableSheet(
                        initialChildSize: 0.3,
                        minChildSize: 0.1,
                        maxChildSize: 1.0,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: ListView(
                              controller: scrollController,
                              children: <Widget>[
                                Center(
                                  child: Container(
                                    width: 32,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        top: 15.0, bottom: 4.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.4),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12.0)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MarkdownBody(
                                      data: currentSpeaker.description +
                                          getEventsMarkdown(
                                              events: currentSpeaker.events,
                                              currentSpeaker: currentSpeaker.id,
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
                );
              },
            ),
    );
  }
}
