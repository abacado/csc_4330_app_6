import 'package:flutter_test/flutter_test.dart';
import 'package:skill_sprout/state/community_store.dart';
import 'package:skill_sprout/state/error_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('store validation messages pass through without a type prefix', () {
    expect(
      friendlyError(ArgumentError('Enter a display name.')),
      'Enter a display name.',
    );
    expect(
      friendlyError(StateError('Join this community before posting.')),
      'Join this community before posting.',
    );
  });

  test('sign-in failures are explained in plain words', () {
    expect(
      friendlyError(
        const AuthException(
          'Invalid login credentials',
          statusCode: '400',
          code: 'invalid_credentials',
        ),
      ),
      'That email and password do not match.',
    );
    expect(
      friendlyError(
        const AuthException('User already registered', code: 'user_already_exists'),
      ),
      contains('already exists'),
    );
    expect(
      friendlyError(const AuthException('slow down', statusCode: '429')),
      contains('Too many attempts'),
    );
  });

  test('database and unknown errors never leak their details', () {
    const duplicate = PostgrestException(
      message: 'duplicate key value violates unique constraint "hobbies_name_unique"',
      code: '23505',
    );
    final messages = [
      friendlyError(duplicate),
      friendlyError(const PostgrestException(message: 'relation missing', code: '42P01')),
      friendlyError(const AuthException('internal detail', code: 'unexpected_failure')),
      friendlyError(Exception('SocketException: host lookup failed')),
      friendlyError(ArgumentError()),
    ];
    for (final message in messages) {
      expect(message, isNot(contains('Exception')));
      expect(message, isNot(contains('constraint')));
      expect(message, isNot(contains('relation')));
      expect(message, isNot(contains('internal detail')));
      expect(message, isNot(contains('Invalid argument')));
    }
  });

  test('replying to a post that is gone gives a readable reason', () async {
    final store = CommunityStore(persistDemo: false);
    addTearDown(store.dispose);
    await store.initialize();
    await store.enterDemo('Abigail');
    try {
      await store.reply('missing', 'Hello');
      fail('Expected the reply to be rejected.');
    } on StateError catch (e) {
      expect(friendlyError(e), contains('no longer available'));
    }
  });
}
