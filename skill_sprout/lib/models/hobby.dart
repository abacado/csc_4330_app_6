import 'package:material_ui/material_ui.dart';

enum SkillLevel {
  beginner('Beginner', 'Show me the basics and let me ask questions.'),
  intermediate('Intermediate', 'I know the basics and want to keep improving.'),
  advanced('Advanced', 'I can answer questions and help beginners.'),
  pro('Pro', 'I can mentor beginners and vouch for gear.');

  const SkillLevel(this.label, this.blurb);

  final String label;
  final String blurb;

  /// Advanced and Pro members answer questions instead of following the guide.
  bool get canMentor => index >= SkillLevel.advanced.index;
}

class GuideStep {
  const GuideStep(this.title, this.body);

  final String title;
  final String body;
}

class Hobby {
  const Hobby({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.tint,
    required this.basics,
  });

  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final Color tint;
  final List<GuideStep> basics;
}

class UserHobby {
  const UserHobby({required this.hobby, required this.level});

  final Hobby hobby;
  final SkillLevel level;
}
