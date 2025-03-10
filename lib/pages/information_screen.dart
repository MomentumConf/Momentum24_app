import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:momentum24_app/widgets/momentum_appbar.dart';
import 'package:momentum24_app/widgets/info_tile.dart';
import 'package:momentum24_app/pages/information/regulations_screen.dart';
import 'package:momentum24_app/pages/information/songs_screen.dart';
import 'package:momentum24_app/pages/information/speakers_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MomentumAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InfoTile(
            title: AppLocalizations.of(context)!.speakers,
            image: 'assets/images/mowcy.jpg',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SpeakersScreen())),
          ),
          InfoTile(
            title: AppLocalizations.of(context)!.songs,
            image: 'assets/images/teksty.jpg',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SongsScreen())),
          ),
          InfoTile(
            title: AppLocalizations.of(context)!.regulations,
            image: 'assets/images/regulamin.jpg',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegulationsScreen())),
          ),
        ],
      ),
    );
  }
}
