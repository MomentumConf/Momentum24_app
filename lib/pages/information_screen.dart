import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/momentum_appbar.dart';
import '../widgets/info_tile.dart';
import './information/regulations_screen.dart';
import './information/songs_screen.dart';
import './information/speakers_screen.dart';

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
