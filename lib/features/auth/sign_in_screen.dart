import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../routing/routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/hobby_glyph.dart';
import '../onboarding/hobby_picker_screen.dart';
import '../shell/home_shell.dart';

/// Mock auth: any email and a 6+ character password gets you in.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creatingAccount = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final state = AppScope.read(context)..signIn(_email.text);
    final next = state.hobbies.isEmpty
        ? const HobbyPickerScreen(isOnboarding: true)
        : const HomeShell();
    Navigator.of(context).pushReplacement(fadeThroughRoute(next));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const _Wordmark(),
                    const Spacer(),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        for (final (i, hobby)
                            in MockData.hobbies.take(5).indexed)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FadeSlideIn(
                              delay: Duration(milliseconds: 80 * i),
                              child: HobbyGlyph(hobby, size: 44),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Learn it.\nThen pass it on.',
                      style: textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pick up a hobby with people who have been there, and pass along the gear you outgrow.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(
                                Icons.alternate_email_rounded,
                                size: 20,
                              ),
                            ),
                            validator: (v) => (v ?? '').contains('@')
                                ? null
                                : 'Enter a valid email',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                              ),
                            ),
                            validator: (v) => (v ?? '').length >= 6
                                ? null
                                : 'At least 6 characters',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _submit,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _creatingAccount ? 'Create account' : 'Sign in',
                          key: ValueKey(_creatingAccount),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(
                          () => _creatingAccount = !_creatingAccount,
                        ),
                        child: Text(
                          _creatingAccount
                              ? 'I already have an account'
                              : 'New here? Create an account',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.moss,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.eco_outlined, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          'skill sprout',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}
