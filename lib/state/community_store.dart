import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/community_style.dart';
import '../data/mock_data.dart';
import '../models/hobby.dart';

typedef RecordData = Map<String, dynamic>;

/// One page of a query, plus how many rows the whole query matches.
typedef RowPage = ({List<RecordData> rows, int total});

/// Reads a whole query that the server hands back in capped pages. [page] is
/// given how many rows have been read so far and returns the next page.
Future<List<RecordData>> fetchAllRows(
  Future<RowPage> Function(int from) page,
) async {
  final rows = <RecordData>[];
  while (true) {
    final next = await page(rows.length);
    rows.addAll(next.rows);
    if (next.rows.isEmpty || rows.length >= next.total) return rows;
  }
}

/// The social MVP's data boundary. Demo data never mixes with hosted data.
class CommunityStore extends ChangeNotifier {
  CommunityStore({this.client, this.persistDemo = true});

  final SupabaseClient? client;
  final bool persistDemo;
  static const _storageKey = 'skill_sprout_community_v1';
  bool get isCloud => client != null;
  bool ready = false;
  String? userId;
  List<RecordData> profiles = [];
  List<RecordData> posts = [];
  List<RecordData> comments = [];
  List<RecordData> memberships = [];

  /// Communities started by members. The built-in ones live in MockData.
  List<RecordData> communities = [];
  bool get signedIn => userId != null;
  RecordData get profile => profiles.firstWhere(
    (p) => p['id'] == userId,
    orElse: () => {'display_name': 'Friend', 'bio': ''},
  );
  String get name => profile['display_name'] as String;
  Set<String> get joined => memberships
      .where((m) => m['user_id'] == userId)
      .map((m) => m['hobby_id'] as String)
      .toSet();
  String author(String id) =>
      profiles.firstWhere(
            (p) => p['id'] == id,
            orElse: () => {'display_name': 'Community member'},
          )['display_name']
          as String;
  List<RecordData> replies(String postId) =>
      comments.where((c) => c['post_id'] == postId).toList();

  /// Built-in communities followed by member-started ones.
  List<Hobby> get hobbies => [
    ...MockData.hobbies,
    for (final row in communities) _hobbyFrom(row),
  ];

  Hobby hobbyFor(String id) => hobbies.firstWhere(
    (h) => h.id == id,
    orElse: () => Hobby(
      id: id,
      name: 'Community',
      tagline: '',
      icon: communityIcon(null),
      tint: communityTint(communityTints.first),
      basics: const [],
    ),
  );

  Hobby _hobbyFrom(RecordData row) => Hobby(
    id: row['id'] as String,
    name: row['name'] as String,
    tagline: (row['tagline'] as String?) ?? '',
    icon: communityIcon(row['icon'] as String?),
    tint: communityTint((row['tint'] as num?)?.toInt() ?? communityTints.first),
    basics: const [],
  );

  RecordData? communityRow(String id) {
    for (final row in communities) {
      if (row['id'] == id) return row;
    }
    return null;
  }

  /// Who started a member-made community, or null for a built-in one.
  String? creatorOf(String hobbyId) =>
      communityRow(hobbyId)?['created_by'] as String?;

  bool canEdit(String hobbyId) =>
      signedIn && creatorOf(hobbyId) != null && creatorOf(hobbyId) == userId;

  Future<void> initialize() async {
    if (isCloud) {
      userId = client!.auth.currentUser?.id;
      if (signedIn) await refresh();
    } else {
      final saved = persistDemo
          ? await SharedPreferencesAsync().getString(_storageKey)
          : null;
      if (saved != null) {
        final data = jsonDecode(saved) as Map<String, dynamic>;
        profiles = _rows(data['profiles']);
        posts = _rows(data['posts']);
        comments = _rows(data['comments']);
        memberships = _rows(data['memberships']);
        communities = data['communities'] == null
            ? []
            : _rows(data['communities']);
      } else {
        _seed();
      }
    }
    ready = true;
    notifyListeners();
  }

  List<RecordData> _rows(dynamic data) =>
      (data as List).map((v) => Map<String, dynamic>.from(v as Map)).toList();

  void _seed() {
    profiles = [
      {
        'id': 'seed-maya',
        'display_name': 'Maya',
        'bio': 'Making things, one stitch at a time.',
      },
      {
        'id': 'seed-jules',
        'display_name': 'Jules',
        'bio': 'Always up for a new route.',
      },
    ];
    final stories = [
      (
        'climbing',
        'seed-jules',
        'Anyone up for a climbing session?',
        'Looking for a friendly climbing buddy this week. All experience levels welcome!',
      ),
      (
        'crochet',
        'seed-maya',
        'A little progress on my first tote',
        'The edges are finally straight! What are you working on this week?',
      ),
    ];
    posts = [
      for (final (i, story) in stories.indexed)
        {
          'id': 'seed-$i',
          'hobby_id': story.$1,
          'author_id': story.$2,
          'title': story.$3,
          'body': story.$4,
          'kind': i == 0 ? 'Meet up' : 'Project',
          'created_at': DateTime.now()
              .subtract(Duration(hours: i + 1))
              .toIso8601String(),
        },
    ];
  }

  Future<void> _save() async {
    if (!isCloud && persistDemo) {
      await SharedPreferencesAsync().setString(
        _storageKey,
        jsonEncode({
          'profiles': profiles,
          'posts': posts,
          'comments': comments,
          'memberships': memberships,
          'communities': communities,
        }),
      );
    }
    notifyListeners();
  }

  Future<String?> authenticate(
    String email,
    String password, {
    required bool create,
    String displayName = '',
  }) async {
    if (!isCloud) throw StateError('Use the demo entry in local mode.');
    final response = create
        ? await client!.auth.signUp(
            email: email,
            password: password,
            data: {'display_name': displayName.trim()},
          )
        : await client!.auth.signInWithPassword(
            email: email,
            password: password,
          );
    if (response.session == null) {
      return 'Check your email to confirm your account, then sign in.';
    }
    userId = response.user!.id;
    await refresh();
    return null;
  }

  Future<void> enterDemo(String displayName) async {
    if (isCloud) {
      throw StateError('Demo mode is unavailable in a connected build.');
    }
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError('Enter a demo name.');
    userId = 'demo-${name.toLowerCase()}';
    if (!profiles.any((p) => p['id'] == userId)) {
      profiles.add({'id': userId, 'display_name': name, 'bio': ''});
    }
    await _save();
  }

  Future<void> refresh() async {
    if (isCloud && signedIn) {
      // The server caps how many rows one request returns, so every read is
      // either bounded by what is on screen or paged until complete.
      final db = client!;
      final (postRows, membershipRows, hobbyRows) = await (
        db
            .from('community_posts')
            .select()
            .order('created_at', ascending: false)
            .limit(_postLimit),
        db.from('memberships').select().eq('user_id', userId!),
        fetchAllRows(
          (from) => _page(
            db.from('hobbies').select().order('created_at').order('id'),
            from,
          ),
        ),
      ).wait;
      final newPosts = _rows(postRows);

      // Only the replies to the posts that were loaded.
      final postIds = [for (final p in newPosts) p['id']];
      final newComments = postIds.isEmpty
          ? <RecordData>[]
          : await fetchAllRows(
              (from) => _page(
                db
                    .from('community_comments')
                    .select()
                    .inFilter('post_id', postIds)
                    .order('created_at')
                    .order('id'),
                from,
              ),
            );

      // Only the people who appear on screen, asked for in URL-sized batches.
      final people = <Object?>{
        userId,
        for (final p in newPosts) p['author_id'],
        for (final c in newComments) c['author_id'],
        for (final h in hobbyRows) h['created_by'],
      }.nonNulls.toList();
      final profilePages = await Future.wait([
        for (var i = 0; i < people.length; i += _idBatch)
          db
              .from('profiles')
              .select()
              .inFilter(
                'id',
                people.sublist(i, (i + _idBatch).clamp(0, people.length)),
              ),
      ]);

      // Assign only after all reads succeed, preserving the last good screen.
      profiles = [for (final page in profilePages) ..._rows(page)];
      posts = newPosts;
      comments = newComments;
      memberships = _rows(membershipRows);
      final builtIn = {for (final h in MockData.hobbies) h.id};
      communities = hobbyRows
          .where((row) => !builtIn.contains(row['id']))
          .toList();
    }
    notifyListeners();
  }

  static const _postLimit = 100;
  static const _pageSize = 1000;
  static const _idBatch = 100;

  Future<RowPage> _page(
    PostgrestTransformBuilder<PostgrestList> query,
    int from,
  ) async {
    final response = await query
        .range(from, from + _pageSize - 1)
        .count(CountOption.exact);
    return (rows: _rows(response.data), total: response.count);
  }

  void _requireUser() {
    if (!signedIn) throw StateError('Please sign in first.');
  }

  Future<void> join(String hobbyId, bool value) async {
    _requireUser();
    if (!hobbies.any((h) => h.id == hobbyId)) {
      throw ArgumentError('Unknown hobby');
    }
    if (isCloud) {
      if (value) {
        await client!.from('memberships').upsert({
          'user_id': userId,
          'hobby_id': hobbyId,
        });
      } else {
        await client!
            .from('memberships')
            .delete()
            .eq('user_id', userId!)
            .eq('hobby_id', hobbyId);
      }
    }
    memberships.removeWhere(
      (m) => m['user_id'] == userId && m['hobby_id'] == hobbyId,
    );
    if (value) memberships.add({'user_id': userId, 'hobby_id': hobbyId});
    await _save();
  }

  Future<void> publish(
    String hobbyId,
    String title,
    String body,
    String kind,
  ) async {
    _requireUser();
    if (!joined.contains(hobbyId)) {
      throw StateError('Join this community before posting.');
    }
    if (title.trim().isEmpty || body.trim().isEmpty) {
      throw ArgumentError('Add a title and message.');
    }
    if (title.trim().length > 120 ||
        body.trim().length > 4000 ||
        !['Project', 'Question', 'Meet up'].contains(kind)) {
      throw ArgumentError('Check the post length and type.');
    }
    final data = {
      'hobby_id': hobbyId,
      'author_id': userId,
      'title': title.trim(),
      'body': body.trim(),
      'kind': kind,
    };
    if (isCloud) {
      final row = await client!
          .from('community_posts')
          .insert(data)
          .select()
          .single();
      posts.insert(0, row);
    } else {
      posts.insert(0, {
        ...data,
        'id': 'post-${DateTime.now().microsecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    await _save();
  }

  Future<void> reply(String postId, String body) async {
    _requireUser();
    if (body.trim().isEmpty) throw ArgumentError('Write a reply first.');
    if (body.trim().length > 2000) {
      throw ArgumentError('Keep replies under 2000 characters.');
    }
    final post = posts.firstWhere(
      (p) => p['id'] == postId,
      orElse: () => throw StateError(
        'This post is no longer available. Refresh and try again.',
      ),
    );
    if (!joined.contains(post['hobby_id'])) {
      throw StateError('Join this community to reply.');
    }
    final data = {'post_id': postId, 'author_id': userId, 'body': body.trim()};
    if (isCloud) {
      comments.add(
        await client!.from('community_comments').insert(data).select().single(),
      );
    } else {
      comments.add({
        ...data,
        'id': 'reply-${DateTime.now().microsecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    await _save();
  }

  Future<void> updateProfile(String displayName, String bio) async {
    _requireUser();
    if (displayName.trim().isEmpty) {
      throw ArgumentError('Enter a display name.');
    }
    if (displayName.trim().length > 40 || bio.trim().length > 160) {
      throw ArgumentError(
        'Keep your name under 40 characters and bio under 160.',
      );
    }
    final data = {'display_name': displayName.trim(), 'bio': bio.trim()};
    if (isCloud) await client!.from('profiles').update(data).eq('id', userId!);
    profile.addAll(data);
    await _save();
  }

  Future<void> signOut() async {
    if (isCloud) await client!.auth.signOut();
    userId = null;
    if (isCloud) {
      profiles = [];
      posts = [];
      comments = [];
      memberships = [];
      communities = [];
    }
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Member-started communities
  // -------------------------------------------------------------------------

  RecordData _checkCommunity(
    String name,
    String tagline,
    String icon,
    int tint, {
    String? editing,
  }) {
    final cleanName = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final cleanTagline = tagline.trim();
    if (cleanName.length < 2 || cleanName.length > 40) {
      throw ArgumentError('Give the community a name of 2 to 40 characters.');
    }
    if (cleanTagline.isEmpty || cleanTagline.length > 80) {
      throw ArgumentError('Add a tagline of up to 80 characters.');
    }
    if (!communityIcons.containsKey(icon) || !communityTints.contains(tint)) {
      throw ArgumentError('Pick an icon and a colour.');
    }
    final taken = hobbies.any(
      (h) => h.id != editing && h.name.toLowerCase() == cleanName.toLowerCase(),
    );
    if (taken) {
      throw ArgumentError('A community called "$cleanName" already exists.');
    }
    return {
      'name': cleanName,
      'tagline': cleanTagline,
      'icon': icon,
      'tint': tint,
    };
  }

  String _newCommunityId(String name) {
    var slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > 30) slug = slug.substring(0, 30);
    if (slug.isEmpty) slug = 'community';
    final suffix = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return '$slug-$suffix';
  }

  /// Starts a community, makes the creator its first member, and returns it.
  Future<Hobby> createCommunity({
    required String name,
    required String tagline,
    required String icon,
    required int tint,
  }) async {
    _requireUser();
    final data = {
      ..._checkCommunity(name, tagline, icon, tint),
      'id': _newCommunityId(name),
      'created_by': userId,
    };
    if (isCloud) {
      communities.add(
        await client!.from('hobbies').insert(data).select().single(),
      );
    } else {
      communities.add({
        ...data,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    final id = data['id'] as String;
    await join(id, true);
    return hobbyFor(id);
  }

  /// Lets a community's creator change its name, tagline, icon and colour.
  Future<void> updateCommunity(
    String hobbyId, {
    required String name,
    required String tagline,
    required String icon,
    required int tint,
  }) async {
    _requireUser();
    final row = communityRow(hobbyId);
    if (row == null || row['created_by'] != userId) {
      throw StateError('Only the person who started this community can edit it.');
    }
    final data = _checkCommunity(name, tagline, icon, tint, editing: hobbyId);
    if (isCloud) {
      await client!.from('hobbies').update(data).eq('id', hobbyId);
    }
    row.addAll(data);
    await _save();
  }
}
