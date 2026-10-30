import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/hobby.dart';
import '../../models/listing.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/choice_pill.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/hobby_glyph.dart';
import '../../widgets/listing_tile.dart';
import 'create_listing_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _search = TextEditingController();
  ListingType? _type;
  String? _hobbyId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickHobby() async {
    final picked = await showModalBottomSheet<_HobbyChoice>(
      context: context,
      builder: (_) => _HobbyFilterSheet(selectedId: _hobbyId),
    );
    if (picked != null) setState(() => _hobbyId = picked.hobbyId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final results = state.listings(
      hobbyId: _hobbyId,
      type: _type,
      query: _search.text,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CreateListingScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('List an item'),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Market', style: textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Buy, trade, borrow, or give away gear.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search gear, materials, books',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () =>
                                    setState(() => _search.clear()),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      ChoicePill(
                        label: _hobbyId == null
                            ? 'All hobbies'
                            : MockData.hobbyById(_hobbyId!).name,
                        selected: _hobbyId != null,
                        trailingIcon: Icons.expand_more_rounded,
                        onTap: _pickHobby,
                      ),
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        color: AppColors.line,
                      ),
                      for (final type in [null, ...ListingType.values])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoicePill(
                            label: type?.label ?? 'All',
                            selected: _type == type,
                            onTap: () => setState(() => _type = type),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  '${results.length} ${results.length == 1 ? 'listing' : 'listings'}',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ),
            if (results.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 32,
                        color: AppColors.inkMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nothing matches those filters.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => FadeSlideIn(
                    key: ValueKey(results[i].id),
                    delay: Duration(milliseconds: 40 * i.clamp(0, 6)),
                    child: ListingTile(results[i]),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 104)),
          ],
        ),
      ),
    );
  }
}

class _HobbyChoice {
  const _HobbyChoice(this.hobbyId);

  final String? hobbyId;
}

class _HobbyFilterSheet extends StatelessWidget {
  const _HobbyFilterSheet({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    final mine = [for (final h in state.hobbies) h.hobby];
    final others = MockData.hobbies
        .where((h) => state.levelFor(h.id) == null)
        .toList();

    Widget option(String label, String? id, Widget leading) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: leading,
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: selectedId == id
          ? const Icon(Icons.check_rounded, color: AppColors.moss)
          : null,
      onTap: () => Navigator.of(context).pop(_HobbyChoice(id)),
    );

    Widget glyph(Hobby h) => HobbyGlyph(h, size: 34);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          option(
            'All hobbies',
            null,
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.sunken,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.apps_rounded,
                size: 18,
                color: AppColors.inkMuted,
              ),
            ),
          ),
          if (mine.isNotEmpty) ...[
            const _SheetLabel('Yours'),
            for (final h in mine) option(h.name, h.id, glyph(h)),
          ],
          if (others.isNotEmpty) ...[
            const _SheetLabel('Everything else'),
            for (final h in others) option(h.name, h.id, glyph(h)),
          ],
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.inkMuted, letterSpacing: 1),
      ),
    );
  }
}
