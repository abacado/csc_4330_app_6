import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skill_sprout/state/community_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('hosted refresh works with the original hobbies schema', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      final response = request.response;
      response.headers.contentType = ContentType.json;
      if (request.uri.path == '/rest/v1/hobbies') {
        final order = request.uri.queryParameters['order'];
        if (order?.startsWith('created_at.') == true) {
          response.statusCode = HttpStatus.badRequest;
          response.write(
            jsonEncode({
              'code': '42703',
              'message': 'column hobbies.created_at does not exist',
            }),
          );
        } else {
          response.write(
            jsonEncode([
              {'id': 'crochet', 'name': 'Crochet'},
            ]),
          );
        }
      } else if (request.uri.path == '/rest/v1/memberships') {
        response.write(
          jsonEncode([
            {'user_id': 'member', 'hobby_id': 'crochet'},
          ]),
        );
      } else {
        response.write('[]');
      }
      await response.close();
    });

    final client = SupabaseClient(
      'http://127.0.0.1:${server.port}',
      'test-key',
    );
    addTearDown(client.dispose);
    final store = CommunityStore(client: client)..userId = 'member';
    addTearDown(store.dispose);

    await store.refresh();

    expect(store.joined, {'crochet'});
    expect(store.hobbies.where((h) => h.id == 'crochet'), hasLength(1));
  });
}
