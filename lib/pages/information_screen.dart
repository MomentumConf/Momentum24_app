import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/momentum_appbar.dart';
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
          _buildInfoTile(
            context: context,
            title: AppLocalizations.of(context)!.speakers,
            image: 'assets/images/mowcy.jpg',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SpeakersScreen())),
          ),
          _buildInfoTile(
            context: context,
            title: AppLocalizations.of(context)!.songs,
            image: 'assets/images/teksty.jpg',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SongsScreen())),
          ),
          _buildInfoTile(
            context: context,
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

  Widget _buildInfoTile(
      {required BuildContext context,
      required String title,
      required String image,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Image.asset(
                          "/$image",
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.surface,
                              shadows: const <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
