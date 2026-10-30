import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/hobby.dart';
import '../../routing/routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/hobby_glyph.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/listing_tile.dart';
import '../../widgets/post_row.dart';
import '../../widgets/pressable.dart';
import '../../widgets/segmented_tabs.dart';
import '../../widgets/thin_progress.dart';
import '../market/create_listing_screen.dart';

/// A hobby's home: the guide (or mentor queue for Advanced/Pro members),
/// its discussion board, and its listings.
class HobbyScreen extends StatefulWidget {
  const HobbyScreen({super.key, required this.hobbyId});

  final String hobbyId;

  @override
  State<HobbyScreen> createState() => _HobbyScreenState();
}

class _HobbyScreenState extends State<HobbyScreen> {
  int _tab = 0;
  bool _reverse = false;

  void _selectTab(int tab) {
    if (tab == _tab) return;
    setState(() {
      _reverse = tab < _tab;
      _tab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hobby = MockData.hobbyById(widget.hobbyId);
    final level = AppScope.of(context).levelFor(hobby.id);
    final mentoring = level?.canMentor ?? false;

    final content = switch (_tab) {
      0 => mentoring ? _MentorTab(hobby) : _GuideTab(hobby),
      1 => _DiscussionTab(hobby),
      _ => _ListingsTab(hobby),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: CircleIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Hero(
                    tag: 'hobby-glyph-${hobby.id}',
                    child: HobbyGlyph(hobby, size: 56),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hobby.name, style: textTheme.headlineSmall),
                        const SizedBox(height: 3),
                        Text(hobby.tagline, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (level != null) LevelBadge(level),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: SegmentedTabs(
                labels: [
                  mentoring ? 'Mentor' : 'Guide',
                  'Discussion',
                  'Listings',
                ],
                index: _tab,
                onChanged: _selectTab,
              ),
            ),
            Expanded(
              child: PageTransitionSwitcher(
                reverse: _reverse,
                duration: const Duration(milliseconds: 340),
                transitionBuilder: (child, animation, secondaryAnimation) =>
                    SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: AppColors.paper,
                      child: child,
                    ),
                child: KeyedSubtree(key: ValueKey(_tab), child: content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideTab extends StatelessWidget {
  const _GuideTab(this.hobby);

  final Hobby hobby;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final done = state.stepsDone(hobby.id);
    final total = hobby.basics.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          children: [
            Text('The basics', style: textTheme.titleLarge),
            const Spacer(),
            Text(
              '$done of $total',
              style: textTheme.labelMedium?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ThinProgress(total == 0 ? 0 : done / total, height: 6),
        const SizedBox(height: 18),
        for (final (i, step) in hobby.basics.indexed)
          _StepTile(
            number: i + 1,
            step: step,
            done: state.isStepDone(hobby.id, i),
            onTap: () => state.toggleStep(hobby.id, i),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.forum_outlined, color: AppColors.moss, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stuck on something?', style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Advanced and Pro members answer beginner questions.',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    showNote(context, 'Asking a mentor is coming soon.'),
                child: const Text('Ask'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.step,
    required this.done,
    required this.onTap,
  });

  final int number;
  final GuideStep step;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const duration = Duration(milliseconds: 260);
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done
              ? AppColors.mossSoft.withValues(alpha: 0.6)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: done
                ? AppColors.moss.withValues(alpha: 0.25)
                : AppColors.line,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: duration,
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.moss : AppColors.surface,
                border: Border.all(
                  color: done ? AppColors.moss : AppColors.line,
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        key: ValueKey('done'),
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        '$number',
                        key: const ValueKey('todo'),
                        style: textTheme.labelMedium,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    step.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MentorTab extends StatelessWidget {
  const _MentorTab(this.hobby);

  final Hobby hobby;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final open = AppScope.of(context).openQuestionsFor(hobby.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.claySoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.clay,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are mentoring in ${hobby.name}',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Beginners see your answers first. Open questions are below.',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Text('Open questions', style: textTheme.titleLarge),
        ),
        if (open.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Nobody is waiting on an answer right now.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
          )
        else
          for (final post in open)
            PostRow(
              post,
              trailing: TextButton(
                onPressed: () =>
                    showNote(context, 'Answering opens in a later build.'),
                child: const Text('Answer'),
              ),
            ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text('What beginners see', style: textTheme.titleLarge),
        ),
        for (final (i, step) in hobby.basics.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}'.padLeft(2, '0'),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Expanded(child: Text(step.title, style: textTheme.bodyLarge)),
              ],
            ),
          ),
      ],
    );
  }
}

class _DiscussionTab extends StatelessWidget {
  const _DiscussionTab(this.hobby);

  final Hobby hobby;

  @override
  Widget build(BuildContext context) {
    final posts = AppScope.of(context).postsFor(hobby.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton.icon(
            onPressed: () =>
                showNote(context, 'Starting threads is coming soon.'),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Start a thread'),
          ),
        ),
        const SizedBox(height: 4),
        for (final (i, post) in posts.indexed) ...[
          if (i > 0) const Divider(indent: 20, endIndent: 20),
          PostRow(post),
        ],
      ],
    );
  }
}

class _ListingsTab extends StatelessWidget {
  const _ListingsTab(this.hobby);

  final Hobby hobby;

  @override
  Widget build(BuildContext context) {
    final listings = AppScope.of(context).listings(hobbyId: hobby.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreateListingScreen(initialHobbyId: hobby.id),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('List an item'),
        ),
        const SizedBox(height: 14),
        if (listings.isEmpty)
          Text(
            'Nothing listed for ${hobby.name} yet.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
          )
        else
          for (final listing in listings)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListingTile(listing),
            ),
      ],
    );
  }
}
