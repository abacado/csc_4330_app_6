import 'package:material_ui/material_ui.dart';

import '../models/hobby.dart';
import '../theme/app_theme.dart';

Color levelColor(SkillLevel level) =>
    level.canMentor ? AppColors.clay : AppColors.moss;

/// Four dots, filled up to the level. Compact enough to sit beside a name.
class LevelDots extends StatelessWidget {
  const LevelDots(this.level, {super.key, this.color});

  final SkillLevel level;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? levelColor(level);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < SkillLevel.values.length; i++)
          Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 2.5),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= level.index ? c : c.withValues(alpha: 0.22),
            ),
          ),
      ],
    );
  }
}

class LevelBadge extends StatelessWidget {
  const LevelBadge(this.level, {super.key});

  final SkillLevel level;

  @override
  Widget build(BuildContext context) {
    final fg = levelColor(level);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 9, 4),
      decoration: BoxDecoration(
        color: level.canMentor ? AppColors.claySoft : AppColors.mossSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LevelDots(level, color: fg),
          const SizedBox(width: 6),
          Text(
            level.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
