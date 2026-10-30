import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/hobby.dart';
import '../../routing/routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/choice_pill.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/hobby_glyph.dart';
import '../../widgets/segmented_tabs.dart';
import '../shell/home_shell.dart';

/// Pick hobbies and a skill level for each. Used for onboarding and for
/// editing hobbies later from Home or Profile.
class HobbyPickerScreen extends StatefulWidget {
  const HobbyPickerScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  State<HobbyPickerScreen> createState() => _HobbyPickerScreenState();
}

class _HobbyPickerScreenState extends State<HobbyPickerScreen> {
  Map<String, SkillLevel>? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected ??= Map.of(AppScope.read(context).hobbyLevels);
  }

  void _toggle(Hobby hobby) {
    setState(() {
      if (_selected!.remove(hobby.id) == null) {
        _selected![hobby.id] = SkillLevel.beginner;
      }
    });
  }

  void _save() {
    AppScope.read(context).setHobbies(_selected!);
    if (widget.isOnboarding) {
      Navigator.of(context)
          .pushReplacement(fadeThroughRoute(const HomeShell()));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = _selected!;
    final chosen = MockData.hobbies.where((h) => selected.containsKey(h.id));

    return Scaffold(
      appBar: widget.isOnboarding
          ? null
          : AppBar(title: const Text('Your hobbies')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            if (widget.isOnboarding) ...[
              const SizedBox(height: 16),
              Text('What are you into?', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Pick a few and tell us where you are at. You can change this any time.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hobby in MockData.hobbies)
                  ChoicePill(
                    label: hobby.name,
                    selected: selected.containsKey(hobby.id),
                    onTap: () => _toggle(hobby),
                    leading: Icon(
                      hobby.icon,
                      size: 18,
                      color: selected.containsKey(hobby.id)
                          ? AppColors.paper
                          : hobby.tint,
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (chosen.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'How experienced are you?',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                  ],
                  for (final hobby in chosen)
                    FadeSlideIn(
                      key: ValueKey(hobby.id),
                      child: _LevelCard(
                        hobby: hobby,
                        level: selected[hobby.id]!,
                        onChanged: (level) =>
                            setState(() => selected[hobby.id] = level),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: selected.isEmpty ? null : _save,
            child: Text(widget.isOnboarding ? 'Continue' : 'Save'),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.hobby,
    required this.level,
    required this.onChanged,
  });

  final Hobby hobby;
  final SkillLevel level;
  final ValueChanged<SkillLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HobbyGlyph(hobby, size: 32),
              const SizedBox(width: 10),
              Text(hobby.name, style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedTabs(
            labels: [for (final l in SkillLevel.values) l.label],
            index: level.index,
            onChanged: (i) => onChanged(SkillLevel.values[i]),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              level.blurb,
              key: ValueKey(level),
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
