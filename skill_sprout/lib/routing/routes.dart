import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

/// Used for "context switch" navigation (sign in -> app, sign out) where a
/// sideways slide would imply the user can go back.
Route<T> fadeThroughRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 450),
  reverseTransitionDuration: const Duration(milliseconds: 350),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, animation, secondaryAnimation, child) =>
      FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      ),
);

void showNote(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String timeAgo(DateTime time) {
  final d = DateTime.now().difference(time);
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return '${d.inDays ~/ 7}w ago';
}
