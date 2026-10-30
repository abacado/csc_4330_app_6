import 'package:flutter_test/flutter_test.dart';
import 'package:skill_sprout/models/hobby.dart';
import 'package:skill_sprout/models/listing.dart';
import 'package:skill_sprout/state/app_state.dart';

void main() {
  group('AppState', () {
    test('signIn derives a display name from the email', () {
      final state = AppState()..signIn('maya.r@example.com');
      expect(state.isSignedIn, isTrue);
      expect(state.displayName, 'Maya.r');
    });

    test('signOut clears the session and hobbies', () {
      final state = AppState()
        ..signIn('a@b.co')
        ..setHobbies({'crochet': SkillLevel.pro});
      state.signOut();
      expect(state.isSignedIn, isFalse);
      expect(state.hobbies, isEmpty);
    });

    test('mentor levels are advanced and pro only', () {
      expect(SkillLevel.beginner.canMentor, isFalse);
      expect(SkillLevel.intermediate.canMentor, isFalse);
      expect(SkillLevel.advanced.canMentor, isTrue);
      expect(SkillLevel.pro.canMentor, isTrue);
    });

    test('feed only includes posts from chosen hobbies', () {
      final state = AppState()..setHobbies({'climbing': SkillLevel.beginner});
      expect(state.feed, isNotEmpty);
      expect(state.feed.every((p) => p.hobbyId == 'climbing'), isTrue);
    });

    test('toggleStep tracks guide progress', () {
      final state = AppState()
        ..toggleStep('crochet', 0)
        ..toggleStep('crochet', 2);
      expect(state.stepsDone('crochet'), 2);
      state.toggleStep('crochet', 0);
      expect(state.isStepDone('crochet', 0), isFalse);
      expect(state.stepsDone('crochet'), 1);
    });

    test('listings filter by hobby, type, and query', () {
      final state = AppState();
      expect(
        state.listings(hobbyId: 'crochet').every((l) => l.hobbyId == 'crochet'),
        isTrue,
      );
      expect(
        state
            .listings(type: ListingType.free)
            .every((l) => l.type == ListingType.free),
        isTrue,
      );
      expect(state.listings(query: 'canon').single.id, 'l3');
    });

    test('addListing shows up first and under the seller', () {
      final state = AppState()..signIn('sam@x.io');
      state.addListing(
        Listing(
          id: 'new',
          hobbyId: 'guitar',
          title: 'Capo',
          description: '',
          type: ListingType.free,
          sellerName: state.displayName,
          sellerLevel: SkillLevel.beginner,
          condition: 'Good',
          postedAt: DateTime.now(),
        ),
      );
      expect(state.listings().first.id, 'new');
      expect(state.listingsBy('Sam').single.id, 'new');
    });
  });
}
