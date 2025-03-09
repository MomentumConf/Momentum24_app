import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:momentum24_app/pages/information/speaker_details_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/speaker.dart';
import '../../services/data_provider_service.dart';
import '../../widgets/information/speaker_card.dart';

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
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.speakers),
          ),
          body: isLoading || speakers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: speakers.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => buildSpeaker(context, index),
                )),
    );
  }

  Widget buildSpeaker(BuildContext context, int index) {
    final speaker = speakers[index];
    return SpeakerCard(
      speaker: speaker,
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (context) => SpeakerDetailsScreen(speakerId: speaker.id),
        ));
      },
    );
  }
}
