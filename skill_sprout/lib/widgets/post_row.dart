import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../models/post.dart';
import '../routing/routes.dart';
import '../theme/app_theme.dart';
import 'avatar.dart';
import 'level_badge.dart';

/// One forum thread in a list. Rows are separated by dividers rather than
/// boxed in cards to keep long feeds calm.
class PostRow extends StatelessWidget {
  const PostRow(this.post, {super.key, this.showHobby = false, this.trailing});

  final Post post;
  final bool showHobby;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hobby = MockData.hobbyById(post.hobbyId);
    final meta = [
      if (showHobby) hobby.name,
      timeAgo(post.postedAt),
    ].join(' · ');

    return InkWell(
      onTap: () => showNote(context, 'Threads open in a later build.'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(post.authorName, size: 26),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    post.authorName,
                    style: textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 7),
                LevelDots(post.authorLevel),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    meta,
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.title, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 15,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: 5),
                Text('${post.replyCount}', style: textTheme.bodySmall),
                if (post.needsAnswer) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.claySoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Needs an answer',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.clay,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                ?trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
