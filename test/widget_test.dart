// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:peer_studio/main.dart';
import 'package:peer_studio/models/ai_models.dart';
import 'package:peer_studio/services/settings_service.dart';
import 'package:peer_studio/services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = SettingsService();
    await settingsService.init();

    final youtubeService = YoutubeService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(PeerStudioApp(
      initialSettings: UserSettings(),
      settingsService: settingsService,
      youtubeService: youtubeService,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
