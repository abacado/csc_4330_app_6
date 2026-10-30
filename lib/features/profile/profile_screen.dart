import 'package:material_ui/material_ui.dart';

import '../../routing/routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/hobby_glyph.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/listing_tile.dart';
import '../../widgets/section_header.dart';
import '../auth/sign_in_screen.dart';
import '../hobby/hobby_screen.dart';
import '../onboarding/hobby_picker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _signOut(BuildContext context) {
    final state = AppScope.read(context);
    Navigator.of(
      context,
    ).pushAndRemoveUntil(fadeThroughRoute(const SignInScreen()), (_) => false);
    state.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final hobbies = state.hobbies;
    final myListings = state.listingsBy(state.displayName);
    final mentoring = hobbies.where((h) => h.level.canMentor).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Avatar(state.displayName, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.displayName, style: textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        [
                          '${hobbies.length} ${hobbies.length == 1 ? 'hobby' : 'hobbies'}',
                          if (mentoring > 0) 'mentoring in $mentoring',
                        ].join(' · '),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
            'Hobbies',
            actionLabel: 'Edit',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HobbyPickerScreen(),
              ),
            ),
          ),
          _Group(
            children: [
              for (final h in hobbies)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: HobbyGlyph(h.hobby, size: 36),
                  title: Text(h.hobby.name, style: textTheme.titleMedium),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LevelBadge(h.level),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HobbyScreen(hobbyId: h.hobby.id),
                    ),
                  ),
                ),
            ],
          ),
          const SectionHeader('Your listings'),
          if (myListings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Nothing listed yet. Items you post show up here.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            )
          else
            for (final listing in myListings)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ListingTile(listing),
              ),
          const SectionHeader('Account'),
          _Group(
            children: [
              _AccountRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () =>
                    showNote(context, 'Notifications are coming soon.'),
              ),
              _AccountRow(
                icon: Icons.tune_rounded,
                label: 'Settings',
                onTap: () => showNote(context, 'Settings are coming soon.'),
              ),
              _AccountRow(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                color: AppColors.clay,
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rounded, bordered container that separates its rows with hairlines.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.line),
        ),
        child: Column(
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const Divider(indent: 14, endIndent: 14),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.ink,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}
