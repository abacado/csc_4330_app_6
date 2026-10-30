import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class ThinProgress extends StatelessWidget {
  const ThinProgress(this.value, {super.key, this.height = 5});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.sunken,
          borderRadius: BorderRadius.circular(99),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.moss,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}
