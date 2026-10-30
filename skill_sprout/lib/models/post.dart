import 'hobby.dart';

/// A forum thread inside a hobby.
class Post {
  const Post({
    required this.id,
    required this.hobbyId,
    required this.authorName,
    required this.authorLevel,
    required this.title,
    required this.body,
    required this.replyCount,
    required this.isQuestion,
    required this.postedAt,
  });

  final String id;
  final String hobbyId;
  final String authorName;
  final SkillLevel authorLevel;
  final String title;
  final String body;
  final int replyCount;
  final bool isQuestion;
  final DateTime postedAt;

  bool get needsAnswer => isQuestion && replyCount == 0;
}
