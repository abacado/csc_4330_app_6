import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skill_sprout/app.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('walks sign in, onboarding, tabs, hobby, and listing', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SkillSproutApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'gabe@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('What are you into?'), findsOneWidget);

    await tester.tap(find.text('Rock climbing'));
    await tester.tap(find.text('Crochet'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pro').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pro').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Gabe'), findsOneWidget);

    await tester.tap(find.text('Rock climbing').first);
    await tester.pumpAndSettle();
    expect(find.text('The basics'), findsOneWidget);
    await tester.tap(find.text('Start indoors'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 4'), findsOneWidget);
    await tester.tap(find.text('Discussion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crochet').first);
    await tester.pumpAndSettle();
    expect(find.text('Open questions'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Market'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Free').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ten-year-old starter'));
    await tester.pumpAndSettle();
    expect(find.text('Request it'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('List an item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post listing'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a price'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });
}
