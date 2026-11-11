import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skill_sprout/app.dart';
import 'package:skill_sprout/state/community_store.dart';

const _previewKey = ValueKey('preview-boundary');
Future<void> capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_PREVIEWS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_previewKey),
  );
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final folder = Directory('build/previews')..createSync(recursive: true);
  await File('${folder.path}/$name.png')
      .writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}

void main() {
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
      for (final name in ['DMSans', 'Fraunces']) {
        await (FontLoader(
          name,
        )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets(
    'member joins, publishes, switches identity, and replies on phone',
    (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = CommunityStore(persistDemo: false);
      addTearDown(store.dispose);
      await tester.pumpWidget(
        RepaintBoundary(
          key: _previewKey,
          child: SkillSproutApp(store: store),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() => capturePreview(tester, 'welcome'));
      await tester.enterText(find.byType(TextFormField).first, 'Abigail');
      await tester.ensureVisible(find.text('Enter demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enter demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Communities'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crochet').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Join community'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join community'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('New post'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New post'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'My first scarf',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Would love some feedback!',
      );
      await tester.ensureVisible(find.text('Publish post'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish post'));
      await tester.pumpAndSettle();
      expect(store.posts.first['title'], 'My first scarf');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Switch demo member'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch demo member'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Jordan');
      await tester.ensureVisible(find.text('Enter demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enter demo'));
      await tester.pumpAndSettle();
      // Join as the second member; neither identity nor membership leaks.
      expect(store.joined, isEmpty);
      await store.join('crochet', true);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('My first scarf'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('My first scarf'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Love the colors!');
      await tester.ensureVisible(find.text('Send reply'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send reply'));
      await tester.pumpAndSettle();
      expect(find.text('Love the colors!'), findsOneWidget);
      expect(store.author(store.comments.last['author_id']), 'Jordan');
      expect(tester.takeException(), isNull);
      await tester.runAsync(() => capturePreview(tester, 'conversation'));
    },
  );
}
