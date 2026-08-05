import 'package:flutter/material.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.offlineTitle),
      ),
      body: Center(
        child: Text(l10n.offlineTodo),
      ),
    );
  }
}
