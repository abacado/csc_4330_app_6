import 'package:flutter_test/flutter_test.dart';
import 'package:skill_sprout/state/community_store.dart';

void main() {
  group('fetchAllRows', () {
    final all = [for (var i = 0; i < 5; i++) <String, dynamic>{'id': i}];

    test('keeps asking until every row the server reports is read', () async {
      final asked = <int>[];
      final rows = await fetchAllRows((from) async {
        asked.add(from);
        // A server that never returns more than two rows at a time.
        return (rows: all.skip(from).take(2).toList(), total: all.length);
      });
      expect(rows, all);
      expect(asked, [0, 2, 4]);
    });

    test('makes one request when everything fits in a page', () async {
      var calls = 0;
      final rows = await fetchAllRows((from) async {
        calls++;
        return (rows: all, total: all.length);
      });
      expect(rows, all);
      expect(calls, 1);
    });

    test('stops on an empty page even if the total is never reached', () async {
      final rows = await fetchAllRows(
        (from) async => (rows: all.skip(from).take(3).toList(), total: 99),
      );
      expect(rows, all);
      expect(await fetchAllRows((_) async => (rows: <RecordData>[], total: 0)), isEmpty);
    });
  });

  test('membership gates publishing and replies; two identities share conversations', () async {
    final store = CommunityStore(persistDemo: false);
    addTearDown(store.dispose);
    await store.initialize();
    await store.enterDemo('Abigail');
    await expectLater(
      store.publish('crochet', 'Scarf', 'Hello', 'Project'),
      throwsStateError,
    );
    await store.join('crochet', true);
    await store.publish('crochet', 'Scarf', 'Hello', 'Project');
    final id = store.posts.first['id'] as String;
    await store.signOut();
    await store.enterDemo('Jordan');
    expect(store.joined, isEmpty);
    await expectLater(store.reply(id, 'Hello back'), throwsStateError);
    await store.join('crochet', true);
    await expectLater(store.reply(id, '   '), throwsArgumentError);
    await store.reply(id, 'Hello back');
    await store.signOut();
    await store.enterDemo('Abigail');
    expect(store.joined, contains('crochet'));
    expect(store.replies(id).single['body'], 'Hello back');
    expect(store.author(store.replies(id).single['author_id']), 'Jordan');
    await store.join('crochet', false);
    await expectLater(
      store.publish('crochet', 'Again', 'Hello', 'Project'),
      throwsStateError,
    );
  });

  test('members start communities, join them, and only creators can edit', () async {
    final store = CommunityStore(persistDemo: false);
    addTearDown(store.dispose);
    await store.initialize();
    await store.enterDemo('Abigail');

    // Validation: name, tagline, icon, colour and unique names.
    await expectLater(
      store.createCommunity(name: 'A', tagline: 'x', icon: 'art', tint: 0x4E7A4F),
      throwsArgumentError,
    );
    await expectLater(
      store.createCommunity(name: 'Painting', tagline: '  ', icon: 'art', tint: 0x4E7A4F),
      throwsArgumentError,
    );
    await expectLater(
      store.createCommunity(name: 'Painting', tagline: 'Colour', icon: 'nope', tint: 0x4E7A4F),
      throwsArgumentError,
    );
    await expectLater(
      store.createCommunity(name: 'crochet', tagline: 'Again', icon: 'craft', tint: 0x4E7A4F),
      throwsArgumentError,
    );

    final painting = await store.createCommunity(
      name: '  Watercolour   painting ',
      tagline: 'Brushes, paper, and happy accidents',
      icon: 'art',
      tint: 0x3F7C80,
    );
    expect(painting.name, 'Watercolour painting');
    expect(store.hobbies.map((h) => h.id), contains(painting.id));
    expect(store.joined, contains(painting.id));
    expect(store.canEdit(painting.id), isTrue);
    expect(store.canEdit('crochet'), isFalse);

    // The creator's community works like any other.
    await store.publish(painting.id, 'First wash', 'Hello', 'Project');
    await store.updateCommunity(
      painting.id,
      name: 'Watercolours',
      tagline: 'Wet on wet',
      icon: 'art',
      tint: 0x6B5288,
    );
    expect(store.hobbyFor(painting.id).name, 'Watercolours');

    // Another member can join and post, but not edit.
    await store.signOut();
    await store.enterDemo('Jordan');
    expect(store.canEdit(painting.id), isFalse);
    await expectLater(
      store.updateCommunity(
        painting.id,
        name: 'Mine now',
        tagline: 'Nope',
        icon: 'art',
        tint: 0x6B5288,
      ),
      throwsStateError,
    );
    await store.join(painting.id, true);
    await store.publish(painting.id, 'Hi all', 'New here', 'Question');
    expect(
      store.posts.where((p) => p['hobby_id'] == painting.id),
      hasLength(2),
    );
  });
}
