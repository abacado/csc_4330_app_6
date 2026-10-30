import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../models/hobby.dart';
import '../models/listing.dart';
import '../models/post.dart';

/// Single source of truth for the signed-in session. Backed by [MockData]
/// for now; methods here are the seam where a real backend will plug in.
class AppState extends ChangeNotifier {
  AppState({List<Listing>? listings, List<Post>? posts})
    : _listings = List.of(listings ?? MockData.listings),
      _posts = List.of(posts ?? MockData.posts);

  final List<Listing> _listings;
  final List<Post> _posts;
  final Map<String, SkillLevel> _hobbyLevels = {};
  final Map<String, Set<int>> _completedSteps = {};
  String? _displayName;

  // Session

  bool get isSignedIn => _displayName != null;
  String get displayName => _displayName ?? '';

  void signIn(String email) {
    final handle = email.split('@').first.trim();
    _displayName = handle.isEmpty
        ? 'Friend'
        : '${handle[0].toUpperCase()}${handle.substring(1)}';
    notifyListeners();
  }

  void signOut() {
    _displayName = null;
    _hobbyLevels.clear();
    _completedSteps.clear();
    notifyListeners();
  }

  // Hobbies

  Map<String, SkillLevel> get hobbyLevels => Map.unmodifiable(_hobbyLevels);

  List<UserHobby> get hobbies => [
    for (final hobby in MockData.hobbies)
      if (_hobbyLevels[hobby.id] case final level?)
        UserHobby(hobby: hobby, level: level),
  ];

  SkillLevel? levelFor(String hobbyId) => _hobbyLevels[hobbyId];

  void setHobbies(Map<String, SkillLevel> levels) {
    _hobbyLevels
      ..clear()
      ..addAll(levels);
    notifyListeners();
  }

  // Guide progress

  bool isStepDone(String hobbyId, int step) =>
      _completedSteps[hobbyId]?.contains(step) ?? false;

  int stepsDone(String hobbyId) => _completedSteps[hobbyId]?.length ?? 0;

  void toggleStep(String hobbyId, int step) {
    final steps = _completedSteps.putIfAbsent(hobbyId, () => {});
    if (!steps.remove(step)) steps.add(step);
    notifyListeners();
  }

  // Forum

  List<Post> get feed =>
      _newestFirst(_posts.where((p) => _hobbyLevels.containsKey(p.hobbyId)));

  List<Post> postsFor(String hobbyId) =>
      _newestFirst(_posts.where((p) => p.hobbyId == hobbyId));

  List<Post> openQuestionsFor(String hobbyId) =>
      postsFor(hobbyId).where((p) => p.needsAnswer).toList();

  // Market

  List<Listing> listings({
    String? hobbyId,
    ListingType? type,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    final matches = _listings.where(
      (l) =>
          (hobbyId == null || l.hobbyId == hobbyId) &&
          (type == null || l.type == type) &&
          (q.isEmpty ||
              l.title.toLowerCase().contains(q) ||
              l.description.toLowerCase().contains(q)),
    );
    return matches.toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  List<Listing> get listingsForMyHobbies =>
      listings().where((l) => _hobbyLevels.containsKey(l.hobbyId)).toList();

  List<Listing> listingsBy(String sellerName) =>
      listings().where((l) => l.sellerName == sellerName).toList();

  void addListing(Listing listing) {
    _listings.add(listing);
    notifyListeners();
  }

  static List<Post> _newestFirst(Iterable<Post> posts) =>
      posts.toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt));
}

/// Exposes [AppState] to the widget tree. Use [of] in build methods so the
/// widget rebuilds on change, and [read] inside callbacks.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
