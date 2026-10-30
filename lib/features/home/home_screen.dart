import 'package:material_ui/material_ui.dart';

import '../../models/hobby.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/hobby_glyph.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/listing_tile.dart';
import '../../widgets/post_row.dart';
import '../../widgets/pressable.dart';
import '../../widgets/section_header.dart';
import '../../widgets/thin_progress.dart';
import '../hobby/hobby_screen.dart';
import '../onboarding/hobby_picker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenMarket});

  final VoidCallback onOpenMarket;

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final hobbies = state.hobbies;
    final feed = state.feed;
    final listings = state.listingsForMyHobbies.take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.displayName,
                          style: textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Avatar(state.displayName, size: 42),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(
            'Your hobbies',
            actionLabel: 'Edit',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HobbyPickerScreen(),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: hobbies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => FadeSlideIn(
                delay: Duration(milliseconds: 60 * i),
                child: _HobbyCard(hobbies[i]),
              ),
            ),
          ),
        ),
        if (listings.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              'Fresh in the market',
              actionLabel: 'See all',
              onAction: onOpenMarket,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 184,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: listings.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) => ListingCard(listings[i]),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(
          child: SectionHeader(
            'From your circles',
            padding: EdgeInsets.fromLTRB(20, 28, 8, 0),
          ),
        ),
        if (feed.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Quiet so far. Threads from your hobbies show up here.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ),
          )
        else
          SliverList.separated(
            itemCount: feed.length,
            separatorBuilder: (_, _) =>
                const Divider(indent: 20, endIndent: 20),
            itemBuilder: (context, i) => PostRow(feed[i], showHobby: true),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _HobbyCard extends StatelessWidget {
  const _HobbyCard(this.userHobby);

  final UserHobby userHobby;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final hobby = userHobby.hobby;
    final level = userHobby.level;

    final Widget status;
    if (level.canMentor) {
      final waiting = state.openQuestionsFor(hobby.id).length;
      status = Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: waiting > 0 ? AppColors.clay : AppColors.line,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              waiting == 0
                  ? 'No open questions'
                  : '$waiting ${waiting == 1 ? 'question needs' : 'questions need'} you',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: waiting > 0 ? AppColors.clay : AppColors.inkMuted,
              ),
            ),
          ),
        ],
      );
    } else {
      final done = state.stepsDone(hobby.id);
      final total = hobby.basics.length;
      status = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$done of $total basics', style: textTheme.bodySmall),
          const SizedBox(height: 6),
          ThinProgress(total == 0 ? 0 : done / total),
        ],
      );
    }

    return Pressable(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => HobbyScreen(hobbyId: hobby.id)),
      ),
      child: Container(
        width: 196,
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
                Hero(
                  tag: 'hobby-glyph-${hobby.id}',
                  child: HobbyGlyph(hobby, size: 36),
                ),
                const Spacer(),
                LevelDots(level),
              ],
            ),
            const Spacer(),
            Text(
              hobby.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            status,
          ],
        ),
      ),
    );
  }
}
