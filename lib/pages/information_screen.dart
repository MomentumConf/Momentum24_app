import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:momentum24_app/models/social_media.dart';
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/widgets/momentum_appbar.dart';
import 'package:momentum24_app/widgets/info_tile.dart';
import 'package:momentum24_app/pages/information/regulations_screen.dart';
import 'package:momentum24_app/pages/information/songs_screen.dart';
import 'package:momentum24_app/pages/information/speakers_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  SocialMedia? _socialMedia;

  @override
  void initState() {
    super.initState();
    _fetchSocialMedia();
  }

  Future<void> _fetchSocialMedia() async {
    final data = await GetIt.I<DataProviderService>().getSocialMedia();
    setState(() {
      _socialMedia = data;
    });
    log(_socialMedia.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MomentumAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_socialMedia != null &&
              (_socialMedia!.facebook != null ||
                  _socialMedia!.tiktok != null ||
                  _socialMedia!.instagram != null ||
                  _socialMedia!.website != null))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_socialMedia!.facebook != null)
                    IconButton(
                      icon: const Icon(Icons.facebook),
                      color: Theme.of(context).colorScheme.tertiary,
                      onPressed: () => launchUrl(
                        Uri.parse(_socialMedia!.facebook!),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  if (_socialMedia!.tiktok != null)
                    IconButton(
                      icon: const Icon(Icons.tiktok),
                      color: Theme.of(context).colorScheme.tertiary,
                      onPressed: () => launchUrl(
                        Uri.parse(_socialMedia!.tiktok!),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  if (_socialMedia!.instagram != null)
                    IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            'assets/images/instagram.svg',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.tertiary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      color: Theme.of(context).colorScheme.tertiary,
                      onPressed: () => launchUrl(
                        Uri.parse(_socialMedia!.instagram!),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  if (_socialMedia!.website != null)
                    IconButton(
                      icon: const Icon(Icons.web),
                      color: Theme.of(context).colorScheme.tertiary,
                      onPressed: () => launchUrl(
                        Uri.parse(_socialMedia!.website!),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ],
              ),
            ),
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
