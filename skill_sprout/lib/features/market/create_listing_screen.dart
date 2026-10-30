import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/hobby.dart';
import '../../models/listing.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/choice_pill.dart';
import '../../widgets/segmented_tabs.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key, this.initialHobbyId});

  final String? initialHobbyId;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  static const _conditions = ['New', 'Like new', 'Good', 'Well-loved'];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  String? _hobbyId;
  ListingType _type = ListingType.sale;
  String _condition = 'Good';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hobbyId ??=
        widget.initialHobbyId ??
        AppScope.read(context).hobbies.firstOrNull?.hobby.id ??
        MockData.hobbies.first.id;
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final state = AppScope.read(context);
    state.addListing(
      Listing(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        hobbyId: _hobbyId!,
        title: _title.text.trim(),
        description: _description.text.trim(),
        type: _type,
        price: _type == ListingType.sale ? double.parse(_price.text) : null,
        sellerName: state.displayName,
        sellerLevel: state.levelFor(_hobbyId!) ?? SkillLevel.beginner,
        condition: _condition,
        postedAt: DateTime.now(),
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Your listing is live.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine = [for (final h in AppScope.of(context).hobbies) h.hobby];
    final hobbyOptions = mine.isEmpty ? MockData.hobbies : mine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New listing'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const _FieldLabel('Hobby'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hobby in hobbyOptions)
                  ChoicePill(
                    label: hobby.name,
                    selected: _hobbyId == hobby.id,
                    onTap: () => setState(() => _hobbyId = hobby.id),
                    leading: Icon(
                      hobby.icon,
                      size: 18,
                      color: _hobbyId == hobby.id
                          ? AppColors.paper
                          : hobby.tint,
                    ),
                  ),
              ],
            ),
            const _FieldLabel('Offer it as'),
            SegmentedTabs(
              labels: [for (final t in ListingType.values) t.verb],
              index: _type.index,
              onChanged: (i) => setState(() => _type = ListingType.values[i]),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _type == ListingType.sale
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Price',
                          prefixText: '\$ ',
                        ),
                        validator: (v) =>
                            _type == ListingType.sale &&
                                double.tryParse(v ?? '') == null
                            ? 'Enter a price'
                            : null,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const _FieldLabel('Title'),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What are you offering?',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Give it a title' : null,
            ),
            const _FieldLabel('Condition'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _conditions)
                  ChoicePill(
                    label: c,
                    selected: _condition == c,
                    onTap: () => setState(() => _condition = c),
                  ),
              ],
            ),
            const _FieldLabel('Details'),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Size, brand, how long you have had it, pickup details',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _submit,
            child: const Text('Post listing'),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
