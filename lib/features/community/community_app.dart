import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../data/community_style.dart';
import '../../models/hobby.dart';
import '../../routing/routes.dart';
import '../../state/community_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/soft.dart';

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unable to complete this action. $error')),
  );
}


// ---------------------------------------------------------------------------
// Layout helpers
// ---------------------------------------------------------------------------

/// Windows at least this wide get the desktop layout (sidebar, wide grids).
const wideBreakpoint = 1000.0;

bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideBreakpoint;

/// The selected main tab: 0 Home, 1 Communities, 2 Profile.
final shellTab = ValueNotifier<int>(0);

void selectTab(BuildContext context, int tab) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  shellTab.value = tab;
}

void openCommunity(BuildContext context, CommunityStore store, Hobby hobby) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityPage(store: store, hobbyId: hobby.id),
      ),
    );

/// Opens the form to start a community, or to edit [editing].
void openCommunityEditor(
  BuildContext context,
  CommunityStore store, {
  Hobby? editing,
  String initialName = '',
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => CommunityEditor(
      store: store,
      editing: editing,
      initialName: initialName,
    ),
  ),
);

void openPost(BuildContext context, CommunityStore store, RecordData post) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PostDetail(store: store, post: post),
      ),
    );

void openCompose(
  BuildContext context,
  CommunityStore store, {
  String? hobbyId,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => ComposePost(store: store, hobbyId: hobbyId),
  ),
);

(Color, Color) kindColors(String kind) => switch (kind) {
  'Meet up' => (AppColors.powder, AppColors.powderInk),
  'Question' => (AppColors.blush, AppColors.blushInk),
  _ => (AppColors.sage, AppColors.mossDeep),
};

String plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

EdgeInsets pagePadding(BuildContext context, {bool nav = false}) =>
    isWide(context)
    ? const EdgeInsets.only(bottom: 24)
    : EdgeInsets.fromLTRB(20, 8, 20, nav ? 130 : 32);

typedef NavItem = ({String label, IconData icon, IconData selectedIcon});

const navItems = <NavItem>[
  (label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home_rounded),
  (label: 'Communities', icon: Icons.eco_outlined, selectedIcon: Icons.eco),
  (
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];

// ---------------------------------------------------------------------------
// Root
// ---------------------------------------------------------------------------

class CommunityRoot extends StatefulWidget {
  const CommunityRoot({super.key, required this.store});
  final CommunityStore store;
  @override
  State<CommunityRoot> createState() => _CommunityRootState();
}

class _CommunityRootState extends State<CommunityRoot> {
  late Future<void> _loading;
  @override
  void initState() {
    super.initState();
    _loading = widget.store.initialize();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('We could not load your community.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      setState(() => _loading = widget.store.initialize()),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }
      if (!widget.store.ready) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return ListenableBuilder(
        listenable: widget.store,
        builder: (_, _) => widget.store.signedIn
            ? SocialShell(store: widget.store)
            : WelcomeScreen(store: widget.store),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Welcome / sign in
// ---------------------------------------------------------------------------

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.store});
  final CommunityStore store;
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController();
  bool _create = false, _busy = false;
  String? _notice;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      if (widget.store.isCloud) {
        final notice = await widget.store.authenticate(
          _email.text.trim(),
          _password.text,
          create: _create,
          displayName: _name.text,
        );
        if (mounted) setState(() => _notice = notice);
      } else {
        await widget.store.enterDemo(_name.text);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _formSection(BuildContext context, {bool large = false}) {
    final text = Theme.of(context).textTheme;
    final cloud = widget.store.isCloud;
    final label = _busy
        ? 'One moment…'
        : !cloud
        ? 'Enter demo'
        : _create
        ? 'Create account'
        : 'Sign in';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cloud
              ? (_create ? 'Put down roots.' : 'Welcome back.')
              : 'Explore the community demo',
          style: large ? text.headlineSmall : text.titleLarge,
        ),
        const SizedBox(height: 8),
        if (!cloud)
          Text(
            'Local demo · Saved on this device. Use different names to try two members. This is not a real login.',
            style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_create || !cloud) ...[
                TextFormField(
                  controller: _name,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 8),
              ],
              if (cloud) ...[
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      (v ?? '').contains('@') ? null : 'Enter an email',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => (v ?? '').length < 6
                      ? 'Use at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 18),
              ],
              if (_notice != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_notice!),
                ),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label),
                    if (!_busy) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
              ),
              if (cloud) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _create = !_create),
                  child: Text(
                    _create
                        ? 'Already a member? Sign in'
                        : 'New here? Create an account',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final hero = WaveBanner(
      eyebrow: 'Rooted in shared interests',
      title: 'Find your people.\nGrow together.',
      subtitle:
          'Share what you make. Find someone to practice with. Make room for a new connection.',
      sprig: true,
      sprigSize: wide ? const Size(140, 210) : const Size(72, 108),
      titleSize: wide ? 60 : 32,
      minHeight: wide ? 0 : 290,
      radius: wide ? 40 : 32,
      waves: const [
        AppColors.blushLight,
        AppColors.sageLight,
        AppColors.powder,
      ],
      padding: wide
          ? const EdgeInsets.fromLTRB(48, 48, 48, 140)
          : const EdgeInsets.fromLTRB(24, 26, 24, 80),
      leading: wide
          ? const Padding(
              padding: EdgeInsets.only(bottom: 72),
              child: AppLogo(),
            )
          : null,
    );

    if (wide) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: hero),
                const SizedBox(width: 24),
                SizedBox(
                  width: 460,
                  child: Center(
                    child: SingleChildScrollView(
                      child: SoftCard(
                        radius: 36,
                        padding: const EdgeInsets.all(36),
                        child: _formSection(context, large: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 22),
                  hero,
                  const SizedBox(height: 26),
                  _formSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App frame: floating pill nav on phones, sidebar on desktop
// ---------------------------------------------------------------------------

class SocialShell extends StatefulWidget {
  const SocialShell({super.key, required this.store});
  final CommunityStore store;
  @override
  State<SocialShell> createState() => _SocialShellState();
}

class _SocialShellState extends State<SocialShell> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    shellTab.value = 0;
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      await widget.store.refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: shellTab,
    builder: (context, tab, _) => AppFrame(
      store: widget.store,
      tab: tab,
      onRefresh: _busy ? null : _refresh,
      child: tab == 2
          ? SocialProfile(store: widget.store)
          : CommunityFeed(
              key: ValueKey(tab),
              store: widget.store,
              communitiesOnly: tab == 1,
            ),
    ),
  );
}

class AppFrame extends StatelessWidget {
  const AppFrame({
    super.key,
    required this.store,
    required this.child,
    this.tab,
    this.onRefresh,
    this.showNav = true,
    this.showHeader = true,
  });

  final CommunityStore store;
  final Widget child;
  final int? tab;
  final VoidCallback? onRefresh;

  /// Phone only: the floating bottom nav and the top app bar.
  final bool showNav, showHeader;

  @override
  Widget build(BuildContext context) {
    if (isWide(context)) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 256,
                  child: SideBar(store: store, tab: tab),
                ),
                const SizedBox(width: 24),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      extendBody: true,
      appBar: showHeader
          ? AppBar(
              toolbarHeight: 64,
              titleSpacing: 20,
              title: const Text(
                'skill sprout',
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: AppColors.ink,
                ),
              ),
              actions: [
                if (!store.isCloud)
                  const Center(
                    child: PillTag(
                      'LOCAL DEMO',
                      height: 28,
                      textColor: AppColors.mossDeep,
                    ),
                  ),
                const SizedBox(width: 10),
                SoftIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Refresh community',
                  onPressed: onRefresh,
                ),
                const SizedBox(width: 16),
              ],
            )
          : null,
      body: showHeader ? child : SafeArea(bottom: false, child: child),
      bottomNavigationBar: showNav
          ? PillNavBar(tab: tab, onSelect: (i) => selectTab(context, i))
          : null,
    );
  }
}

class PillNavBar extends StatelessWidget {
  const PillNavBar({super.key, required this.tab, required this.onSelect});
  final int? tab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.paper.withValues(alpha: 0), AppColors.paper],
        stops: const [0, 0.45],
      ),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(34),
            boxShadow: AppDecor.raised(1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final (i, item) in navItems.indexed)
                _NavPill(
                  item: item,
                  selected: i == tab,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: item.label,
    child: Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.sage : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 48,
            constraints: const BoxConstraints(minWidth: 48),
            padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 21,
                  color: selected ? AppColors.mossDeep : AppColors.inkMuted,
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mossDeep,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SideBar extends StatelessWidget {
  const SideBar({super.key, required this.store, this.tab});
  final CommunityStore store;
  final int? tab;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      decoration: AppDecor.card(radius: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: AppLogo(serif: true),
          ),
          const SizedBox(height: 28),
          for (final (i, item) in navItems.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SideItem(
                item: item,
                selected: i == tab,
                onTap: () => selectTab(context, i),
              ),
            ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('YOUR COMMUNITIES', style: eyebrowStyle),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: store.joined.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      'Join a community and it will show up here.',
                      style: text.bodySmall,
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final id in store.joined)
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () =>
                              openCommunity(context, store, store.hobbyFor(id)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                HobbyBadge(store.hobbyFor(id)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    store.hobbyFor(id).name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => openCommunityEditor(context, store),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Start a community'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: pillStyle(
              background: AppColors.blush,
              foreground: AppColors.blushInk,
              height: 52,
            ),
            onPressed: store.joined.isEmpty
                ? null
                : () => openCompose(context, store),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 18),
                SizedBox(width: 8),
                Text('New post'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 6),
              InitialAvatar(store.name, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  store.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!store.isCloud) const PillTag('DEMO', height: 24),
              const SizedBox(width: 6),
              SoftIconButton(
                icon: Icons.refresh_rounded,
                tooltip: 'Refresh community',
                size: 34,
                onPressed: () async {
                  try {
                    await store.refresh();
                  } catch (e) {
                    if (context.mounted) showError(context, e);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.mossDeep : AppColors.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.sage : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feeds: home, communities list, a single community
// ---------------------------------------------------------------------------

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key, required this.store, required this.hobbyId});
  final CommunityStore store;
  final String hobbyId;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => AppFrame(
      store: store,
      tab: 1,
      showNav: false,
      showHeader: false,
      child: CommunityFeed(store: store, hobby: store.hobbyFor(hobbyId)),
    ),
  );
}

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({
    super.key,
    required this.store,
    this.communitiesOnly = false,
    this.hobby,
  });
  final CommunityStore store;
  final bool communitiesOnly;
  final Hobby? hobby;
  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  String _query = '';
  bool _mine = false, _busy = false;

  Future<void> _refresh() async {
    try {
      await widget.store.refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _toggleJoin(Hobby hobby) async {
    setState(() => _busy = true);
    try {
      await widget.store.join(
        hobby.id,
        !widget.store.joined.contains(hobby.id),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final showRail =
        wide && widget.hobby == null && !widget.communitiesOnly;
    return LayoutBuilder(
      builder: (context, constraints) {
        final rail = showRail && constraints.maxWidth >= 980;
        final list = RefreshIndicator(
          color: AppColors.moss,
          onRefresh: _refresh,
          child: ListView(
            padding: wide
                ? const EdgeInsets.only(bottom: 24)
                : EdgeInsets.fromLTRB(
                    20,
                    widget.hobby == null ? 4 : 8,
                    20,
                    widget.hobby == null ? 130 : 32,
                  ),
            children: [
              _banner(context, wide),
              const SizedBox(height: 24),
              if (widget.communitiesOnly)
                ..._communities(context, wide)
              else
                ..._feed(context, wide),
            ],
          ),
        );
        if (!rail) return list;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: list),
            const SizedBox(width: 24),
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: _Rail(store: widget.store),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _banner(BuildContext context, bool wide) {
    final store = widget.store, hobby = widget.hobby;
    if (hobby != null) {
      final joined = store.joined.contains(hobby.id);
      final deep = deepen(hobby.tint);
      return WaveBanner(
        background: pastel(hobby.tint, 0.38),
        waves: [
          pastel(hobby.tint, 0.18),
          AppColors.surface.withValues(alpha: 0.55),
          AppColors.sageLight,
        ],
        eyebrow: 'A place to grow together',
        eyebrowColor: deep,
        title: hobby.name,
        titleSize: wide ? 46 : 38,
        subtitle: hobby.tagline,
        subtitleColor: deep,
        sprig: true,
        minHeight: wide ? 300 : 0,
        padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 20, wide ? 32 : 20, 72),
        leading: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              SoftIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              if (store.canEdit(hobby.id)) ...[
                SoftIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit community',
                  onPressed: () =>
                      openCommunityEditor(context, store, editing: hobby),
                ),
                const SizedBox(width: 12),
              ],
              HobbyBadge(hobby, size: 52, onPastel: true),
            ],
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (store.creatorOf(hobby.id) != null)
                PillTag(
                  store.creatorOf(hobby.id) == store.userId
                      ? 'Started by you'
                      : 'Started by ${store.author(store.creatorOf(hobby.id)!)}',
                  color: AppColors.surface.withValues(alpha: 0.8),
                  textColor: AppColors.ink,
                  icon: Icons.eco_outlined,
                  height: 30,
                ),
              if (joined)
                const PillTag(
                  'Joined',
                  color: AppColors.moss,
                  textColor: Colors.white,
                  icon: Icons.check_rounded,
                  height: 30,
                ),
              FilledButton(
                style: joined
                    ? pillStyle(
                        background: AppColors.surface,
                        foreground: AppColors.ink,
                      )
                    : pillStyle(),
                onPressed: _busy ? null : () => _toggleJoin(hobby),
                child: Text(joined ? 'Leave community' : 'Join community'),
              ),
            ],
          ),
        ),
      );
    }
    if (widget.communitiesOnly) {
      return WaveBanner(
        background: AppColors.powderLight,
        waves: [
          AppColors.surface.withValues(alpha: 0.6),
          AppColors.sageLight,
          AppColors.blushLight,
        ],
        eyebrow: 'Find your corner',
        eyebrowColor: AppColors.powderInk,
        title: wide
            ? 'Shared interests. Common ground.'
            : 'Shared interests.\nCommon ground.',
        titleSize: wide ? 40 : 26,
        minHeight: wide ? 190 : 150,
        padding: EdgeInsets.fromLTRB(wide ? 36 : 22, wide ? 34 : 22, 22, 60),
      );
    }
    return WaveBanner(
      eyebrow: 'Hello, ${store.name}',
      title: 'Something good\nis growing here.',
      subtitle: 'A project to share. A question to ask. Someone who gets it.',
      titleSize: wide ? 40 : 26,
      sprig: true,
      sprigSize: wide ? const Size(90, 135) : const Size(60, 90),
      minHeight: wide ? 230 : 0,
      padding: EdgeInsets.fromLTRB(wide ? 36 : 22, wide ? 34 : 22, 22, 64),
    );
  }

  List<Widget> _communities(BuildContext context, bool wide) {
    final store = widget.store;
    final hobbies = store.hobbies
        .where((h) => h.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final text = Theme.of(context).textTheme;
    return [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Text(
            'Every community',
            style: text.titleLarge?.copyWith(fontSize: wide ? 22 : 19),
          ),
          FilledButton(
            style: pillStyle(
              background: AppColors.blush,
              foreground: AppColors.blushInk,
              height: 42,
            ),
            onPressed: () => openCommunityEditor(context, store),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 18),
                SizedBox(width: 6),
                Text('Start a community'),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        decoration: const InputDecoration(
          hintText: 'Find a hobby community',
          prefixIcon: Icon(Icons.search_rounded),
        ),
        onChanged: (v) => setState(() => _query = v),
      ),
      const SizedBox(height: 18),
      if (hobbies.isEmpty)
        SoftCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No communities match that search.',
                style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: pillStyle(),
                onPressed: () => openCommunityEditor(
                  context,
                  store,
                  initialName: _query.trim(),
                ),
                child: Text(
                  _query.trim().isEmpty
                      ? 'Start a community'
                      : 'Start "${_query.trim()}"',
                ),
              ),
            ],
          ),
        )
      else
        LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: hobbies.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: math.max(2, (constraints.maxWidth / 250).floor()),
              mainAxisSpacing: wide ? 20 : 14,
              crossAxisSpacing: wide ? 20 : 14,
              mainAxisExtent: wide ? 176 : 122,
            ),
            itemBuilder: (context, i) => HobbyTile(
              hobby: hobbies[i],
              joined: store.joined.contains(hobbies[i].id),
              large: wide,
              onTap: () => openCommunity(context, store, hobbies[i]),
            ),
          ),
        ),
    ];
  }

  List<Widget> _feed(BuildContext context, bool wide) {
    final store = widget.store, hobby = widget.hobby;
    final text = Theme.of(context).textTheme;
    final posts = store.posts
        .where(
          (p) =>
              (hobby == null || p['hobby_id'] == hobby.id) &&
              (!_mine || store.joined.contains(p['hobby_id'])) &&
              '${p['title']} ${p['body']}'.toLowerCase().contains(
                _query.toLowerCase(),
              ),
        )
        .toList();
    final canPost =
        store.joined.isNotEmpty &&
        (hobby == null || store.joined.contains(hobby.id));

    final search = TextField(
      decoration: const InputDecoration(
        hintText: 'Search conversations',
        prefixIcon: Icon(Icons.search_rounded),
      ),
      onChanged: (v) => setState(() => _query = v),
    );
    final filters = SegmentedPills(
      semanticLabel: 'Show posts from',
      options: const ['All', 'My communities'],
      value: _mine ? 'My communities' : 'All',
      onChanged: (v) => setState(() => _mine = v == 'My communities'),
    );

    return [
      Row(
        children: [
          Expanded(
            child: Text(
              'On common ground',
              style: text.titleLarge?.copyWith(fontSize: wide ? 22 : 19),
            ),
          ),
          FilledButton(
            style: pillStyle(
              background: AppColors.blush,
              foreground: AppColors.blushInk,
              height: 42,
            ),
            onPressed: canPost
                ? () => openCompose(context, store, hobbyId: hobby?.id)
                : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 18),
                SizedBox(width: 6),
                Text('New post'),
              ],
            ),
          ),
        ],
      ),
      if (store.joined.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Join a community to share a project or start a conversation.',
            style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
        ),
      const SizedBox(height: 16),
      if (hobby == null && wide)
        Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            filters,
          ],
        )
      else ...[
        search,
        if (hobby == null) ...[
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: filters),
        ],
      ],
      const SizedBox(height: 20),
      if (posts.isEmpty)
        SoftCard(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Room for something new. Start a conversation or explore another community.',
            style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
        )
      else
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final post in posts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: PostCard(store: store, post: post),
                    ),
                ],
              );
            }
            final width = (constraints.maxWidth - 18) / 2;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                for (final post in posts)
                  SizedBox(
                    width: width,
                    child: PostCard(store: store, post: post),
                  ),
              ],
            );
          },
        ),
    ];
  }
}

class HobbyTile extends StatelessWidget {
  const HobbyTile({
    super.key,
    required this.hobby,
    required this.joined,
    required this.onTap,
    this.large = false,
  });
  final Hobby hobby;
  final bool joined, large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    color: pastel(hobby.tint, 0.32),
    radius: large ? 30 : 26,
    padding: EdgeInsets.all(large ? 20 : 16),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HobbyBadge(hobby, size: large ? 46 : 38, onPastel: true),
            const Spacer(),
            if (joined)
              const PillTag(
                'Joined',
                color: AppColors.moss,
                textColor: Colors.white,
                height: 22,
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hobby.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: large ? 18 : 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hobby.tagline,
              maxLines: large ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: large ? 13 : 12,
                color: deepen(hobby.tint),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Rail extends StatelessWidget {
  const _Rail({required this.store});
  final CommunityStore store;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bio = '${store.profile['bio'] ?? ''}'.trim();
    final started = store.posts
        .where((p) => p['author_id'] == store.userId)
        .length;
    final suggestions = store.hobbies
        .where((h) => !store.joined.contains(h.id))
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftCard(
          color: AppColors.sageLight,
          radius: 30,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialAvatar(store.name, size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: text.titleMedium),
                        if (bio.isNotEmpty)
                          Text(
                            bio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: AppColors.mossDeep,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PillTag(
                    plural(store.joined.length, 'community', 'communities'),
                    color: AppColors.surface,
                    textColor: AppColors.ink,
                  ),
                  PillTag(
                    plural(started, 'post', 'posts'),
                    color: AppColors.surface,
                    textColor: AppColors.ink,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 20),
          SoftCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find your corner', style: text.titleMedium),
                const SizedBox(height: 10),
                for (final h in suggestions)
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => openCommunity(context, store, h),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          HobbyBadge(h, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  h.tagline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => shellTab.value = 1,
                  child: const Text('See all communities'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Posts
// ---------------------------------------------------------------------------

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.store,
    required this.post,
    this.openable = true,
  });
  final CommunityStore store;
  final RecordData post;
  final bool openable;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hobby = store.hobbyFor('${post['hobby_id']}');
    final kind = '${post['kind']}';
    final (kindBg, kindFg) = kindColors(kind);
    final author = store.author(post['author_id']);
    final created = DateTime.tryParse('${post['created_at'] ?? ''}');
    final replies = store.replies(post['id']).length;
    return SoftCard(
      radius: openable ? AppRadius.lg : 32,
      padding: EdgeInsets.all(openable ? 20 : 26),
      onTap: openable ? () => openPost(context, store, post) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HobbyBadge(hobby, size: openable ? 32 : 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hobby.name,
                  style: const TextStyle(
                    color: AppColors.moss,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PillTag(kind, color: kindBg, textColor: kindFg),
            ],
          ),
          SizedBox(height: openable ? 14 : 18),
          Text(
            '${post['title']}',
            style: openable
                ? text.titleLarge?.copyWith(fontSize: 17.5)
                : text.headlineSmall?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            '${post['body']}',
            maxLines: openable ? 4 : null,
            overflow: openable ? TextOverflow.ellipsis : null,
            style: (openable ? text.bodyMedium : text.bodyLarge)?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          SizedBox(height: openable ? 16 : 20),
          Row(
            children: [
              InitialAvatar(author, size: openable ? 26 : 32),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  created == null
                      ? author
                      : '$author · ${timeAgo(created.toLocal())}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
                color: AppColors.moss,
              ),
              const SizedBox(width: 6),
              Text(
                plural(replies, 'reply', 'replies'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ComposePost extends StatefulWidget {
  const ComposePost({super.key, required this.store, this.hobbyId});
  final CommunityStore store;
  final String? hobbyId;
  @override
  State<ComposePost> createState() => _ComposePostState();
}

class _ComposePostState extends State<ComposePost> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(), _body = TextEditingController();
  late String _hobby;
  String _kind = 'Project';
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _hobby =
        widget.hobbyId != null && widget.store.joined.contains(widget.hobbyId)
        ? widget.hobbyId!
        : widget.store.joined.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.store.publish(_hobby, _title.text, _body.text, _kind);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget label(String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.inkMuted,
        ),
      ),
    );
    return AppFrame(
      store: widget.store,
      showNav: false,
      showHeader: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _form,
            child: ListView(
              padding: pagePadding(context),
              children: [
                Row(
                  children: [
                    SoftIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Plant a conversation', style: text.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'A work in progress belongs here, too.',
                  style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: 26),
                label('Community'),
                DropdownButtonFormField<String>(
                  initialValue: _hobby,
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  icon: const Icon(Icons.expand_more_rounded),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: HobbyBadge(widget.store.hobbyFor(_hobby), size: 28),
                    ),
                  ),
                  items: [
                    for (final id in widget.store.joined)
                      DropdownMenuItem(
                        value: id,
                        child: Text(widget.store.hobbyFor(id).name),
                      ),
                  ],
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _hobby = v!),
                ),
                const SizedBox(height: 20),
                label('Post type'),
                SegmentedPills(
                  semanticLabel: 'Post type',
                  expand: true,
                  options: const ['Project', 'Question', 'Meet up'],
                  value: _kind,
                  onChanged: _busy ? null : (v) => setState(() => _kind = v),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _title,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Give your post a title'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _body,
                  maxLength: 4000,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'What would you like to share?',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Write a message' : null,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _busy ? null : _publish,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(_busy ? 'Publishing…' : 'Publish post'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostDetail extends StatefulWidget {
  const PostDetail({super.key, required this.store, required this.post});
  final CommunityStore store;
  final RecordData post;
  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _reply = TextEditingController();
  bool _busy = false;
  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_reply.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.store.reply(widget.post['id'], _reply.text);
      _reply.clear();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final text = Theme.of(context).textTheme;
      final replies = store.replies(widget.post['id']);
      return AppFrame(
        store: store,
        showNav: false,
        showHeader: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: pagePadding(context),
              children: [
                Row(
                  children: [
                    SoftIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Conversation', style: text.titleLarge),
                    ),
                    SoftIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Refresh replies',
                      onPressed: () async {
                        try {
                          await store.refresh();
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PostCard(store: store, post: widget.post, openable: false),
                const SizedBox(height: 28),
                Text('Keep it growing', style: text.titleLarge),
                const SizedBox(height: 16),
                for (final reply in replies)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReplyBubble(
                      author: store.author(reply['author_id']),
                      body: '${reply['body']}',
                      mine: reply['author_id'] == store.userId,
                    ),
                  ),
                if (replies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Be the first to say hello.',
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (store.joined.contains(widget.post['hobby_id']))
                  SoftCard(
                    radius: 30,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _reply,
                          maxLength: 2000,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Write a reply',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FilledButton(
                          onPressed: _busy ? null : _send,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_busy ? 'Sending…' : 'Send reply'),
                              const SizedBox(width: 8),
                              const Icon(Icons.send_rounded, size: 17),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Join this community from the Communities tab to reply.',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ReplyBubble extends StatelessWidget {
  const _ReplyBubble({
    required this.author,
    required this.body,
    required this.mine,
  });
  final String author, body;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final avatar = mine ? AppColors.blush : AppColors.powder;
    final avatarInk = mine ? AppColors.blushInk : AppColors.powderInk;
    final bubble = mine ? AppColors.blushLight : AppColors.powderLight;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialAvatar(author, size: 36, color: avatar, textColor: avatarInk),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.fromLTRB(16, 12, 18, 14),
            decoration: BoxDecoration(
              color: bubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: avatarInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

class SocialProfile extends StatefulWidget {
  const SocialProfile({super.key, required this.store});
  final CommunityStore store;
  @override
  State<SocialProfile> createState() => _SocialProfileState();
}

class _SocialProfileState extends State<SocialProfile> {
  late final _name = TextEditingController(text: widget.store.name);
  late final _bio = TextEditingController(
    text: widget.store.profile['bio'] ?? '',
  );
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final text = Theme.of(context).textTheme;
    final started = store.posts
        .where((p) => p['author_id'] == store.userId)
        .length;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: pagePadding(context, nav: true),
          children: [
            WaveBanner(
              background: AppColors.sageLight,
              waves: [
                AppColors.powder,
                AppColors.surface.withValues(alpha: 0.7),
                AppColors.blushLight,
              ],
              eyebrow: 'Your corner of the garden',
              eyebrowColor: AppColors.mossDeep,
              minHeight: 210,
              titleWidget: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppDecor.raised(),
                    ),
                    child: InitialAvatar(store.name, size: 64),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      store.name,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineMedium?.copyWith(fontSize: 32),
                    ),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PillTag(
                      plural(store.joined.length, 'community', 'communities'),
                      color: AppColors.surface.withValues(alpha: 0.85),
                      textColor: AppColors.ink,
                      height: 30,
                    ),
                    PillTag(
                      plural(
                        started,
                        'conversation started',
                        'conversations started',
                      ),
                      color: AppColors.surface.withValues(alpha: 0.85),
                      textColor: AppColors.ink,
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _name,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bio,
                    maxLength: 160,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'A little about you',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            try {
                              await store.updateProfile(_name.text, _bio.text);
                              if (context.mounted) {
                                showNote(context, 'Profile saved');
                              }
                            } catch (e) {
                              if (context.mounted) showError(context, e);
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: const Text('Save profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text('Your communities', style: text.titleLarge),
            const SizedBox(height: 12),
            if (store.joined.isEmpty)
              Text(
                'Find your first community in the Communities tab.',
                style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final id in store.joined)
                    _CommunityChip(
                      hobby: store.hobbyFor(id),
                      onTap: () => openCommunity(context, store, store.hobbyFor(id)),
                    ),
                ],
              ),
            const SizedBox(height: 26),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await store.signOut();
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(store.isCloud ? 'Sign out' : 'Switch demo member'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityChip extends StatelessWidget {
  const _CommunityChip({required this.hobby, required this.onTap});
  final Hobby hobby;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: pastel(hobby.tint, 0.32),
    shape: const StadiumBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HobbyBadge(hobby, size: 32, onPastel: true),
            const SizedBox(width: 8),
            Text(
              hobby.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Start / edit a community
// ---------------------------------------------------------------------------

class CommunityEditor extends StatefulWidget {
  const CommunityEditor({
    super.key,
    required this.store,
    this.editing,
    this.initialName = '',
  });
  final CommunityStore store;

  /// The community being edited, or null to start a new one.
  final Hobby? editing;
  final String initialName;

  @override
  State<CommunityEditor> createState() => _CommunityEditorState();
}

class _CommunityEditorState extends State<CommunityEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _tagline;
  late String _icon;
  late int _tint;
  bool _busy = false;

  bool get _editing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final row = _editing
        ? widget.store.communityRow(widget.editing!.id)
        : null;
    _name = TextEditingController(
      text: widget.editing?.name ?? widget.initialName,
    );
    _tagline = TextEditingController(text: widget.editing?.tagline ?? '');
    final savedIcon = row?['icon'] as String?;
    _icon = communityIcons.containsKey(savedIcon) ? savedIcon! : 'eco';
    final savedTint = (row?['tint'] as num?)?.toInt();
    _tint = communityTints.contains(savedTint)
        ? savedTint!
        : communityTints[widget.store.communities.length %
              communityTints.length];
  }

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_editing) {
        await widget.store.updateCommunity(
          widget.editing!.id,
          name: _name.text,
          tagline: _tagline.text,
          icon: _icon,
          tint: _tint,
        );
        if (mounted) {
          showNote(context, 'Community updated');
          Navigator.of(context).pop();
        }
      } else {
        final hobby = await widget.store.createCommunity(
          name: _name.text,
          tagline: _tagline.text,
          icon: _icon,
          tint: _tint,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) =>
                  CommunityPage(store: widget.store, hobbyId: hobby.id),
            ),
          );
        }
      }
    } on ArgumentError catch (e) {
      if (mounted) showNote(context, '${e.message}');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tint = communityTint(_tint);
    final preview = Hobby(
      id: 'preview',
      name: _name.text.trim().isEmpty ? 'Your community' : _name.text.trim(),
      tagline: _tagline.text.trim().isEmpty
          ? 'A line about what you do together'
          : _tagline.text.trim(),
      icon: communityIcon(_icon),
      tint: tint,
      basics: const [],
    );
    Widget label(String value) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.inkMuted,
        ),
      ),
    );

    return AppFrame(
      store: widget.store,
      tab: 1,
      showNav: false,
      showHeader: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _form,
            child: ListView(
              padding: pagePadding(context),
              children: [
                Row(
                  children: [
                    SoftIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  _editing ? 'Edit community' : 'Start a community',
                  style: text.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _editing
                      ? 'Changes show up for every member right away.'
                      : 'Plant a corner for a hobby that is missing. You will be its first member.',
                  style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 260,
                    height: 130,
                    child: ExcludeSemantics(
                      child: HobbyTile(
                        hobby: preview,
                        joined: true,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _name,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.length < 2) return 'Use at least 2 characters';
                    final taken = widget.store.hobbies.any(
                      (h) =>
                          h.id != widget.editing?.id &&
                          h.name.toLowerCase() == value.toLowerCase(),
                    );
                    return taken ? 'That community already exists' : null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagline,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Tagline',
                    hintText: 'e.g. Brushes, paper, and happy accidents',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Add a short tagline' : null,
                ),
                const SizedBox(height: 18),
                label('Icon'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final entry in communityIcons.entries)
                      _PickerCircle(
                        semanticLabel: 'Icon: ${entry.key}',
                        selected: entry.key == _icon,
                        fill: entry.key == _icon
                            ? pastel(tint, 0.4)
                            : AppColors.surface,
                        onTap: _busy
                            ? null
                            : () => setState(() => _icon = entry.key),
                        child: Icon(
                          entry.value,
                          size: 22,
                          color: entry.key == _icon
                              ? deepen(tint)
                              : AppColors.inkMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                label('Colour'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final (i, rgb) in communityTints.indexed)
                      _PickerCircle(
                        semanticLabel: 'Colour ${i + 1}',
                        selected: rgb == _tint,
                        fill: pastel(communityTint(rgb), 0.45),
                        onTap: _busy ? null : () => setState(() => _tint = rgb),
                        child: rgb == _tint
                            ? Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: deepen(communityTint(rgb)),
                              )
                            : Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: communityTint(rgb),
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _editing ? Icons.check_rounded : Icons.eco_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _busy
                            ? 'One moment…'
                            : _editing
                            ? 'Save changes'
                            : 'Create community',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerCircle extends StatelessWidget {
  const _PickerCircle({
    required this.semanticLabel,
    required this.selected,
    required this.fill,
    required this.onTap,
    required this.child,
  });
  final String semanticLabel;
  final bool selected;
  final Color fill;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    button: true,
    selected: selected,
    inMutuallyExclusiveGroup: true,
    child: Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.moss : Colors.transparent,
          width: 2,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppDecor.raised(0.6),
        ),
        child: Material(
          color: fill,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 44,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    ),
  );
}
