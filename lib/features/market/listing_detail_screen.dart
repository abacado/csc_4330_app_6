import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/listing.dart';
import '../../routing/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/listing_tile.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  String get _actionLabel => switch (listing.type) {
    ListingType.sale => 'Message seller',
    ListingType.trade => 'Propose a trade',
    ListingType.lend => 'Ask to borrow',
    ListingType.free => 'Request it',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hobby = MockData.hobbyById(listing.hobbyId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.paper,
            flexibleSpace: FlexibleSpaceBar(
              background: ListingThumb(listing, radius: 0, iconSize: 64),
            ),
            title: CircleIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
            titleSpacing: 16,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TypePill(listing.type),
                      const Spacer(),
                      Text(
                        timeAgo(listing.postedAt),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(listing.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    listing.priceLabel,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.moss,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _Fact(label: 'Hobby', value: hobby.name),
                          const VerticalDivider(width: 1),
                          _Fact(label: 'Condition', value: listing.condition),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('About this item', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(listing.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Avatar(listing.sellerName, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.sellerName,
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${listing.sellerLevel.label} in ${hobby.name}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      LevelBadge(listing.sellerLevel),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(52, 52),
                  ),
                  onPressed: () =>
                      showNote(context, 'Saved items are coming soon.'),
                  child: const Icon(Icons.bookmark_border_rounded, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      showNote(context, 'Messaging opens in a later build.'),
                  child: Text(_actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(value, style: textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
