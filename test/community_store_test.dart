import 'package:flutter_test/flutter_test.dart';
import 'package:skill_sprout/state/community_store.dart';

void main() {
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
}
