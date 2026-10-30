import 'package:material_ui/material_ui.dart';

import '../models/hobby.dart';

/// The hobby's icon on a soft tinted tile. Stands in for imagery app-wide.
class HobbyGlyph extends StatelessWidget {
  const HobbyGlyph(this.hobby, {super.key, this.size = 40});

  final Hobby hobby;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hobby.tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(hobby.icon, size: size * 0.52, color: hobby.tint),
    );
  }
}
