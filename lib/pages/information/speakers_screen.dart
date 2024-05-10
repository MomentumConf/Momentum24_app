import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:momentum24_app/pages/information/speaker_details_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/speaker.dart';
import '../../services/data_provider_service.dart';

class SpeakersScreen extends StatefulWidget {
  final String? speaker;
  const SpeakersScreen({super.key, this.speaker});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();
  bool isLoading = true;

  List<Speaker> speakers = [];

  @override
  void initState() {
    super.initState();
    loadSpeakers();
  }

  void loadSpeakers() async {
    final apiData = await _dataProviderService.getSpeakers();

    setState(() {
      speakers = apiData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.speakers),
        ),
        body: isLoading || speakers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: speakers.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => buildSpeaker(context, index),
              ));
  }

  Widget buildSpeaker(BuildContext context, int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 20).clamp(300, 400);
    final speaker = speakers[index];
    return Center(
      child: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (context) => SpeakerDetailsScreen(speakerId: speaker.id),
            ));
          },
          child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(alignment: Alignment.center, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: speaker.coverUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Image.memory(
                          Uri.parse(speaker.coverLqip).data!.contentAsBytes()),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 40,
                    child: Text(
                      speaker.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
              ))),
    );
  }
}
