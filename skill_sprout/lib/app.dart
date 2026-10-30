import 'package:material_ui/material_ui.dart';

import 'features/auth/sign_in_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class SkillSproutApp extends StatefulWidget {
  const SkillSproutApp({super.key});

  @override
  State<SkillSproutApp> createState() => _SkillSproutAppState();
}

class _SkillSproutAppState extends State<SkillSproutApp> {
  final _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: _state,
      child: MaterialApp(
        title: 'Skill Sprout',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SignInScreen(),
      ),
    );
  }
}
