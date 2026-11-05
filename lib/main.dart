import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'state/community_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  try {
    if (url.isEmpty != key.isEmpty) {
      throw StateError(
        'Set both Supabase configuration values, or leave both empty for the local demo.',
      );
    }
    if (url.isNotEmpty && key.isNotEmpty) {
      await Supabase.initialize(url: url, publishableKey: key);
    }
  } catch (_) {
    runApp(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Unable to start the connected app. Check your Supabase URL and publishable key, then restart. See docs/MVP_SETUP.md.',
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  runApp(
    SkillSproutApp(
      store: CommunityStore(
        client: url.isNotEmpty && key.isNotEmpty
            ? Supabase.instance.client
            : null,
      ),
    ),
  );
}
