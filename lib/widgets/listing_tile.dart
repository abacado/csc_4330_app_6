import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../features/market/listing_detail_screen.dart';
import '../models/listing.dart';
import '../routing/routes.dart';
import '../theme/app_theme.dart';

/// Placeholder "photo" for a listing: hobby tint, a faint dot grid, and the
/// hobby icon. Swap for a real image once uploads exist.
class ListingThumb extends StatelessWidget {
  const ListingThumb(
    this.listing, {
    super.key,
    this.width,
    this.height,
    this.radius = 12,
    this.iconSize = 26,
  });

  final Listing listing;
  final double? width;
  final double? height;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tint = MockData.hobbyById(listing.hobbyId).tint;
    final icon = MockData.hobbyById(listing.hobbyId).icon;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: tint.withValues(alpha: 0.16)),
        child: CustomPaint(
          painter: _DotGridPainter(tint.withValues(alpha: 0.16)),
          child: Center(
            child: Icon(icon, size: iconSize, color: tint),
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 11.0;
    for (var x = gap / 2; x < size.width; x += gap) {
      for (var y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.color != color;
}

class TypePill extends StatelessWidget {
  const TypePill(this.type, {super.key});

  final ListingType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 13, color: type.color),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: type.color),
          ),
        ],
      ),
    );
  }
}

/// Opens [ListingDetailScreen] with a container transform from [closed].
class _ListingOpener extends StatelessWidget {
  const _ListingOpener({required this.listing, required this.closed});

  final Listing listing;
  final Widget closed;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 450),
      closedElevation: 0,
      openElevation: 0,
      closedColor: AppColors.surface,
      openColor: AppColors.paper,
      middleColor: AppColors.paper,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.line),
      ),
      openBuilder: (_, _) => ListingDetailScreen(listing: listing),
      closedBuilder: (_, _) => closed,
    );
  }
}

/// Full-width row for lists.
class ListingTile extends StatelessWidget {
  const ListingTile(this.listing, {super.key});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hobby = MockData.hobbyById(listing.hobbyId);
    return _ListingOpener(
      listing: listing,
      closed: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ListingThumb(listing, width: 76, height: 76),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${hobby.name} · ${timeAgo(listing.postedAt)}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      TypePill(listing.type),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          listing.priceLabel,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.moss,
                          ),
                        ),
                      ),
                    ],
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

/// Compact vertical card for horizontal carousels.
class ListingCard extends StatelessWidget {
  const ListingCard(this.listing, {super.key, this.width = 164});

  final Listing listing;
  final double width;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: _ListingOpener(
        listing: listing,
        closed: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListingThumb(listing, height: 96, radius: 12, iconSize: 30),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.priceLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.moss,
                      ),
                    ),
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
