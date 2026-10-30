import 'package:material_ui/material_ui.dart';

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 36});

  final String name;
  final double size;

  static const _palette = [
    Color(0xFF2F5D45),
    Color(0xFFB85C38),
    Color(0xFF4F6A85),
    Color(0xFF6B5288),
    Color(0xFF8A6A4A),
    Color(0xFF3F7C80),
  ];

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.isEmpty
        ? '?'
        : parts.take(2).map((p) => p[0].toUpperCase()).join();
    // Sum of code units rather than hashCode so colors are stable per name.
    final color =
        _palette[name.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
