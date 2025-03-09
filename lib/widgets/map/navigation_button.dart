import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavigationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NavigationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.navigation),
      label: Text(AppLocalizations.of(context)!.navigateTo),
      onPressed: onPressed,
    );
  }
}
