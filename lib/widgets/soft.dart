import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/hobby.dart';
import '../theme/app_theme.dart';

/// Shared building blocks for the "Pastel Garden" look.

/// A pastel version of a hobby's tint, for tile and badge backgrounds.
Color pastel(Color tint, [double strength = 0.3]) =>
    Color.alphaBlend(tint.withValues(alpha: strength), AppColors.surface);

/// A darker version of a hobby's tint that stays readable on its pastel.
Color deepen(Color tint) => Color.lerp(tint, const Color(0xFF000000), 0.42)!;

const eyebrowStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 2,
  color: AppColors.moss,
);

/// Compact pill button style, for buttons that sit in a row.
ButtonStyle pillStyle({
  Color background = AppColors.sage,
  Color foreground = AppColors.mossDeep,
  double height = 44,
}) => FilledButton.styleFrom(
  minimumSize: Size(0, height),
  padding: const EdgeInsets.symmetric(horizontal: 18),
  backgroundColor: background,
  foregroundColor: foreground,
  shadowColor: background,
  elevation: 3,
);

/// The sprout mark plus the wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.serif = false});
  final bool serif;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AppColors.moss.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.eco_outlined,
          size: 20,
          color: AppColors.mossDeep,
        ),
      ),
      const SizedBox(width: 10),
      if (serif)
        const Text(
          'skill sprout',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: AppColors.ink,
          ),
        )
      else
        const Text(
          'SKILL SPROUT',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
            color: AppColors.moss,
          ),
        ),
    ],
  );
}

/// A raised, rounded card with a soft warm shadow. Tappable when [onTap]
/// is given.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.radius = AppRadius.lg,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppDecor.raised(),
    ),
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

/// Round, raised icon button (back, refresh, ...).
class SoftIconButton extends StatelessWidget {
  const SoftIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      enabled: onPressed != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppDecor.raised(0.8),
        ),
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                icon,
                size: size * 0.44,
                color: onPressed == null ? AppColors.inkMuted : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Small rounded label ("Project", "Joined", "LOCAL DEMO").
class PillTag extends StatelessWidget {
  const PillTag(
    this.label, {
    super.key,
    this.color = AppColors.sage,
    this.textColor = AppColors.mossDeep,
    this.icon,
    this.height = 26,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 11),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

/// Round avatar with the person's initial.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(
    this.name, {
    super.key,
    this.size = 30,
    this.color = AppColors.blush,
    this.textColor = AppColors.blushInk,
  });

  final String name;
  final double size;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        trimmed.isEmpty ? '?' : trimmed[0].toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}

/// A hobby's icon on its pastel tint.
class HobbyBadge extends StatelessWidget {
  const HobbyBadge(
    this.hobby, {
    super.key,
    this.size = 32,
    this.onPastel = false,
  });

  final Hobby hobby;
  final double size;

  /// Use a translucent white background when sitting on the hobby's pastel.
  final bool onPastel;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: onPastel
          ? Colors.white.withValues(alpha: 0.6)
          : pastel(hobby.tint, 0.32),
      borderRadius: BorderRadius.circular(size * 0.36),
    ),
    child: Icon(hobby.icon, size: size * 0.52, color: deepen(hobby.tint)),
  );
}

/// Pill-shaped segmented control.
class SegmentedPills extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.expand = false,
    this.semanticLabel,
  });

  final List<String> options;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool expand;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget segment(String option) {
      final selected = option == value;
      return Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        button: true,
        child: Material(
          color: selected ? AppColors.sage : Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onChanged == null ? null : () => onChanged!(option),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.mossDeep : AppColors.inkMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.sunken,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final option in options)
              if (expand)
                Expanded(child: segment(option))
              else
                segment(option),
          ],
        ),
      ),
    );
  }
}

/// Hero panel with layered organic waves, an optional leaf sprig, an
/// eyebrow, a serif title and an optional subtitle.
class WaveBanner extends StatelessWidget {
  const WaveBanner({
    super.key,
    required this.eyebrow,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.background = AppColors.surface,
    this.waves = const [
      AppColors.powder,
      AppColors.sageLight,
      AppColors.blushLight,
    ],
    this.eyebrowColor = AppColors.moss,
    this.subtitleColor = AppColors.inkMuted,
    this.sprig = false,
    this.sprigSize = const Size(72, 108),
    this.leading,
    this.trailing,
    this.titleSize,
    this.minHeight = 170,
    this.radius = 32,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 60),
  });

  final String eyebrow;
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Color background;

  /// Up to three colours: top-right blob, back wave, front wave.
  final List<Color> waves;
  final Color eyebrowColor;
  final Color subtitleColor;
  final bool sprig;
  final Size sprigSize;
  final Widget? leading;
  final Widget? trailing;
  final double? titleSize;
  final double minHeight;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final inset = sprig
        ? padding.copyWith(right: padding.right + sprigSize.width * 0.6)
        : padding;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppDecor.raised(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: WavePainter(background: background, waves: waves),
          child: Stack(
            children: [
              if (sprig)
                Positioned(
                  right: 16,
                  bottom: 30,
                  width: sprigSize.width,
                  height: sprigSize.height,
                  child: const CustomPaint(painter: LeafSprigPainter()),
                ),
              Padding(
                padding: inset,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?leading,
                    Text(
                      eyebrow.toUpperCase(),
                      style: eyebrowStyle.copyWith(color: eyebrowColor),
                    ),
                    const SizedBox(height: 10),
                    if (titleWidget != null)
                      titleWidget!
                    else if (title != null)
                      Text(
                        title!,
                        style: text.headlineMedium?.copyWith(
                          fontSize: titleSize,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        subtitle!,
                        style: text.bodyMedium?.copyWith(
                          color: subtitleColor,
                          fontSize: (titleSize ?? 30) > 40 ? 17 : 14.5,
                        ),
                      ),
                    ],
                    ?trailing,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  const WavePainter({required this.background, required this.waves});

  final Color background;
  final List<Color> waves;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    if (waves.isNotEmpty) {
      final blob = math.min(h * 0.38, 90.0);
      final path = Path()
        ..moveTo(w * 0.58, 0)
        ..cubicTo(w * 0.66, blob * 0.65, w * 0.84, blob * 0.5, w, blob)
        ..lineTo(w, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = waves[0]);
    }
    if (waves.length > 1) {
      final y = h - 62;
      final path = Path()
        ..moveTo(0, y + 8)
        ..cubicTo(w * 0.22, y - 22, w * 0.4, y + 34, w * 0.63, y + 4)
        ..cubicTo(w * 0.8, y - 18, w * 0.93, y - 12, w, y - 8)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(path, Paint()..color = waves[1]);
    }
    if (waves.length > 2) {
      final y = h - 28;
      final path = Path()
        ..moveTo(0, y + 2)
        ..cubicTo(w * 0.26, y - 16, w * 0.48, y + 18, w * 0.74, y - 2)
        ..cubicTo(w * 0.87, y - 10, w * 0.95, y - 8, w, y - 7)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(path, Paint()..color = waves[2]);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    if (oldDelegate.background != background) return true;
    if (oldDelegate.waves.length != waves.length) return true;
    for (var i = 0; i < waves.length; i++) {
      if (oldDelegate.waves[i] != waves[i]) return true;
    }
    return false;
  }
}

/// A little three-leaf sprig, drawn in an 80 x 120 box and scaled to fit.
class LeafSprigPainter extends CustomPainter {
  const LeafSprigPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 80, size.height / 120);
    canvas.drawPath(
      Path()
        ..moveTo(40, 120)
        ..cubicTo(40, 85, 42, 55, 46, 12),
      Paint()
        ..color = const Color(0xFF8DB8A3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    void leaf(List<double> d, Color color) {
      final path = Path()
        ..moveTo(d[0], d[1])
        ..cubicTo(d[2], d[3], d[4], d[5], d[6], d[7])
        ..cubicTo(d[8], d[9], d[10], d[11], d[0], d[1])
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    leaf([43, 48, 22, 40, 12, 26, 14, 10, 32, 14, 42, 28], const Color(0xFFA9CDBB));
    leaf([45, 66, 64, 56, 74, 42, 72, 26, 54, 32, 46, 46], const Color(0xFFB7D6C6));
    leaf([41, 88, 22, 82, 10, 70, 10, 56, 28, 60, 39, 72], const Color(0xFF9DC4B0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(LeafSprigPainter oldDelegate) => false;
}
