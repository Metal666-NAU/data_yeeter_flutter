import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(final BuildContext context) => Card(
        child: Card(
          margin: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                bigText('project home'),
                link(
                  'data_yeeter_flutter',
                  'https://github.com/Metal666-NAU/data_yeeter_flutter',
                ),
                link(
                  'data-yeeter-server',
                  'https://github.com/Metal666-NAU/data-yeeter-server',
                ),
                separator(),
                bigText('used libraries'),
                ...[
                  'async',
                  'desktop_window',
                  'file_picker',
                  'flutter_bloc',
                  'flutter_hooks',
                  'flutter_webrtc',
                  'go_router',
                  'hive',
                  'hive_flutter',
                  'path',
                  'path_provider',
                  'shared_preferences',
                  'url_launcher',
                  'uuid',
                  'web_socket_channel',
                ].map((final dependency) => link(dependency)),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return'),
                )
              ],
            ),
          ),
        ),
      );

  Widget bigText(final String text) => Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 36,
          fontFeatures: [FontFeature.enable('smcp')],
        ),
      );

  Widget link(
    final String name, [
    final String? url,
  ]) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            ElevatedButton(
              onPressed: () async => await launchUrl(
                Uri.parse(url ?? 'https://pub.dev/packages/$name'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      );

  Widget separator() => const SizedBox(height: 6);
}
