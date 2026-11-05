import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/hobby.dart';
import '../../state/community_store.dart';
import '../../theme/app_theme.dart';

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unable to complete this action. $error')),
  );
}

Hobby hobbyFor(String id) => MockData.hobbies.firstWhere(
  (h) => h.id == id,
  orElse: () => MockData.hobbies.first,
);

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

class GardenBanner extends StatelessWidget {
  const GardenBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  final String eyebrow, title, subtitle;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.line),
      borderRadius: BorderRadius.circular(4),
      color: const Color(0xFF24382B),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.eco_outlined, color: AppColors.moss, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.moss,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.inkMuted, height: 1.6),
        ),
      ],
    ),
  );
}

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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SKILL SPROUT',
                  style: TextStyle(
                    letterSpacing: 4,
                    color: AppColors.moss,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                const GardenBanner(
                  eyebrow: 'Rooted in shared interests',
                  title: 'Find your people.\nGrow together.',
                  subtitle: 'Share what you make. Find someone to practice with. Make room for a new connection.',
                ),
                const SizedBox(height: 24),
                Text(
                  widget.store.isCloud
                      ? (_create ? 'Put down roots.' : 'Welcome back.')
                      : 'Explore the community demo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (!widget.store.isCloud)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Local demo · Saved on this device. Use different names to try two members. This is not a real login.',
                      style: TextStyle(color: AppColors.inkMuted),
                    ),
                  ),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      if (_create || !widget.store.isCloud) ...[
                        TextFormField(
                          controller: _name,
                          maxLength: 40,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (widget.store.isCloud) ...[
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) =>
                              (v ?? '').contains('@') ? null : 'Enter an email',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (v) => (v ?? '').length < 6
                              ? 'Use at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_notice != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_notice!),
                        ),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: Text(
                          _busy
                              ? 'One moment…'
                              : !widget.store.isCloud
                              ? 'Enter demo'
                              : _create
                              ? 'Create account'
                              : 'Sign in',
                        ),
                      ),
                      if (widget.store.isCloud)
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
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SocialShell extends StatefulWidget {
  const SocialShell({super.key, required this.store});
  final CommunityStore store;
  @override
  State<SocialShell> createState() => _SocialShellState();
}

class _SocialShellState extends State<SocialShell> {
  int _tab = 0;
  bool _busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('skill sprout'),
      actions: [
        if (!widget.store.isCloud)
          const Center(
            child: Text(
              'LOCAL DEMO',
              style: TextStyle(
                color: AppColors.moss,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        IconButton(
          tooltip: 'Refresh community',
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    await widget.store.refresh();
                  } catch (e) {
                    if (context.mounted) showError(context, e);
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _tab == 2
            ? SocialProfile(store: widget.store)
            : CommunityFeed(
                key: ValueKey(_tab),
                store: widget.store,
                communitiesOnly: _tab == 1,
              ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dynamic_feed_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.eco_outlined),
          label: 'Communities',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
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
  @override
  Widget build(BuildContext context) {
    final store = widget.store, hobby = widget.hobby;
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
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await store.refresh();
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          GardenBanner(
            eyebrow: hobby == null
                ? (widget.communitiesOnly
                      ? 'Find your corner'
                      : 'Hello, ${store.name}')
                : 'A place to grow together',
            title:
                hobby?.name ??
                (widget.communitiesOnly
                    ? 'Shared interests.\nCommon ground.'
                    : 'Something good\nis growing here.'),
            subtitle:
                hobby?.tagline ??
                'A project to share. A question to ask. Someone who gets it.',
          ),
          const SizedBox(height: 22),
          if (hobby != null) ...[
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await store.join(
                          hobby.id,
                          !store.joined.contains(hobby.id),
                        );
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(
                store.joined.contains(hobby.id)
                    ? 'Leave community'
                    : 'Join community',
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.communitiesOnly) ...[
            TextField(
              decoration: const InputDecoration(
                hintText: 'Find a hobby community',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            for (final h in MockData.hobbies.where(
              (h) => h.name.toLowerCase().contains(_query.toLowerCase()),
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Panel(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: Icon(h.icon, color: AppColors.moss),
                    title: Text(h.name),
                    subtitle: Text(
                      store.joined.contains(h.id)
                          ? 'Joined · ${h.tagline}'
                          : h.tagline,
                    ),
                    trailing: const Icon(Icons.arrow_forward, size: 18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ListenableBuilder(
                          listenable: store,
                          builder: (_, _) => Scaffold(
                            appBar: AppBar(title: Text(h.name)),
                            body: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 800,
                                ),
                                child: CommunityFeed(store: store, hobby: h),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!MockData.hobbies.any(
              (h) => h.name.toLowerCase().contains(_query.toLowerCase()),
            ))
              const Text('No communities match that search.'),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'On common ground',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed:
                      store.joined.isEmpty ||
                          (hobby != null && !store.joined.contains(hobby.id))
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ComposePost(store: store, hobbyId: hobby?.id),
                          ),
                        ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New post'),
                ),
              ],
            ),
            if (store.joined.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Join a community to share a project or start a conversation.',
                ),
              ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            if (hobby == null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('My communities only'),
                value: _mine,
                onChanged: (v) => setState(() => _mine = v),
              ),
            const SizedBox(height: 12),
            if (posts.isEmpty)
              const Panel(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Room for something new. Start a conversation or explore another community.',
                  ),
                ),
              ),
            for (final post in posts)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PostCard(store: store, post: post),
              ),
          ],
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.line),
      borderRadius: BorderRadius.circular(4),
    ),
    child: child,
  );
}

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
  Widget build(BuildContext context) => Panel(
    child: InkWell(
      onTap: !openable
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PostDetail(store: store, post: post),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hobbyFor(post['hobby_id']).icon,
                  color: AppColors.moss,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hobbyFor(post['hobby_id']).name,
                    style: const TextStyle(color: AppColors.moss, fontSize: 12),
                  ),
                ),
                Text(
                  post['kind'],
                  style: const TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(post['title'], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              post['body'],
              maxLines: openable ? 4 : null,
              overflow: openable ? TextOverflow.ellipsis : null,
              style: const TextStyle(height: 1.6, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    store.author(post['author_id']),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 15,
                  color: AppColors.moss,
                ),
                const SizedBox(width: 6),
                Text(
                  '${store.replies(post['id']).length} replies',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Plant a conversation')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'A work in progress belongs here, too.',
                style: TextStyle(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _hobby,
                decoration: const InputDecoration(labelText: 'Community'),
                items: [
                  for (final id in widget.store.joined)
                    DropdownMenuItem(value: id, child: Text(hobbyFor(id).name)),
                ],
                onChanged: _busy ? null : (v) => setState(() => _hobby = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Post type'),
                items: [
                  for (final kind in ['Project', 'Question', 'Meet up'])
                    DropdownMenuItem(value: kind, child: Text(kind)),
                ],
                onChanged: _busy ? null : (v) => setState(() => _kind = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                maxLength: 120,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Give your post a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _body,
                maxLength: 4000,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'What would you like to share?',
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Write a message' : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _publish,
                child: Text(_busy ? 'Publishing…' : 'Publish post'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (_, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          IconButton(
            tooltip: 'Refresh replies',
            onPressed: () async {
              try {
                await widget.store.refresh();
              } catch (e) {
                if (context.mounted) showError(context, e);
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PostCard(store: widget.store, post: widget.post, openable: false),
              const SizedBox(height: 24),
              Text(
                'Keep it growing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final reply in widget.store.replies(widget.post['id']))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Panel(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.store.author(reply['author_id']),
                            style: const TextStyle(color: AppColors.moss),
                          ),
                          const SizedBox(height: 8),
                          Text(reply['body']),
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.store.replies(widget.post['id']).isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text('Be the first to say hello.'),
                ),
              if (widget.store.joined.contains(widget.post['hobby_id'])) ...[
                TextField(
                  controller: _reply,
                  maxLength: 2000,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Write a reply'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          if (_reply.text.trim().isEmpty) return;
                          setState(() => _busy = true);
                          try {
                            await widget.store.reply(
                              widget.post['id'],
                              _reply.text,
                            );
                            _reply.clear();
                          } catch (e) {
                            if (context.mounted) showError(context, e);
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        },
                  child: Text(_busy ? 'Sending…' : 'Send reply'),
                ),
              ] else
                const Text(
                  'Join this community from the Communities tab to reply.',
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      GardenBanner(
        eyebrow: 'Your corner of the garden',
        title: widget.store.name,
        subtitle:
            '${widget.store.joined.length} communities · ${widget.store.posts.where((p) => p['author_id'] == widget.store.userId).length} conversations started',
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _name,
        maxLength: 40,
        decoration: const InputDecoration(labelText: 'Display name'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _bio,
        maxLength: 160,
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(labelText: 'A little about you'),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  await widget.store.updateProfile(_name.text, _bio.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile saved')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) showError(context, e);
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
        child: const Text('Save profile'),
      ),
      const SizedBox(height: 24),
      Text('Your communities', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (widget.store.joined.isEmpty)
        const Text('Find your first community in the Communities tab.'),
      for (final id in widget.store.joined)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(hobbyFor(id).icon, color: AppColors.moss),
          title: Text(hobbyFor(id).name),
        ),
      const SizedBox(height: 24),
      OutlinedButton(
        onPressed: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  await widget.store.signOut();
                } catch (e) {
                  if (context.mounted) showError(context, e);
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
        child: Text(widget.store.isCloud ? 'Sign out' : 'Switch demo member'),
      ),
    ],
  );
}
