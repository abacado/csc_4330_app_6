import 'package:material_ui/material_ui.dart';

import 'features/community/community_app.dart';
import 'state/community_store.dart';
import 'theme/app_theme.dart';

class SkillSproutApp extends StatefulWidget {
  const SkillSproutApp({super.key, this.store});
  final CommunityStore? store;
  @override
  State<SkillSproutApp> createState() => _SkillSproutAppState();
}

class _SkillSproutAppState extends State<SkillSproutApp> {
  late final _store = widget.store ?? CommunityStore();
  @override
  void dispose() {
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Skill Sprout',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    home: CommunityRoot(store: _store),
  );
}
