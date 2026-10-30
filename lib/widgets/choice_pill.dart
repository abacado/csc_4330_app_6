import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

/// Selectable pill used for filters and multi-choice pickers.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.paper : AppColors.ink;
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 38,
        padding: EdgeInsets.only(
          left: leading == null ? 14 : 6,
          right: trailingIcon == null ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? AppColors.ink : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: fg),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(trailingIcon, size: 18, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}
