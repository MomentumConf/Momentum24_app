import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:momentum24_app/services/data_provider_service.dart';

class RegulationsScreen extends StatefulWidget {
  const RegulationsScreen({super.key});

  @override
  State<RegulationsScreen> createState() => RegulationsScreenState();
}

class RegulationsScreenState extends State<RegulationsScreen> {
  String regulationContent = "";
  late PackageInfo packageInfo;
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();

  @override
  void initState() {
    super.initState();
    _dataProviderService
        .setNotifier((dynamic value) => updateContent(value as String))
        .getRegulations()
        .then(updateContent);
  }

  void updateContent(String value) async {
    final PackageInfo packageInfoModel = await PackageInfo.fromPlatform();
    setState(() {
      regulationContent = value;
      packageInfo = packageInfoModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.regulations),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: MarkdownBody(data: regulationContent),
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => {
                    showAboutDialog(
                        context: context,
                        applicationName: packageInfo.appName,
                        applicationVersion: packageInfo.version,
                        applicationLegalese:
                            "© ${DateTime.now().year} Bartosz Kazuła (kazula.eu)",
                        applicationIcon: const FlutterLogo(),
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () {
                              launchUrl(Uri.parse(
                                  "http://konferencjamomentum.pl/2018/Polityka_Prywatnosci_MOMENTUM.pdf"));
                            },
                            child: Text(
                                AppLocalizations.of(context)!.privacyPolicy),
                          ),
                        ])
                  },
              child: Text(AppLocalizations.of(context)!.aboutApp)),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                _dataProviderService.clearCache();
              },
              child: Text(AppLocalizations.of(context)!.clearCache))
        ],
      ),
    );
  }
}
