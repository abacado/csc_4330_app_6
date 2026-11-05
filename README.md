# Skill Sprout

A Flutter community app for people who share hobbies. Find your people, share a
project, ask a question, and grow together.

## Run the MVP now

```powershell
flutter pub get
flutter run -d chrome --web-port 5173
```

Without Supabase configuration, the app runs an explicitly labeled local demo.
Enter a display name, join a community, publish a post, and reply. Profiles,
memberships, posts, and comments are saved on this device. Switch demo members
from Profile to demonstrate two people. Keep the same browser and port to retain
browser data. Demo identities are not real accounts and do not sync across devices.

## Connect real accounts and shared data

Follow [the setup and presentation guide](docs/MVP_SETUP.md). It includes the
Supabase database script, account setup, run/build commands, a two-member demo,
and teammate handoff notes. No custom server is required.

## Current features

- Dark forest/soil theme with sprout-green accents and sharp card edges.
- Browse, search, join, and leave eight hobby communities.
- Community feed with all-community and joined-community views.
- Publish projects, questions, and meetup suggestions as text posts.
- Read and add replies; profile display name and bio editing.
- Local demo persistence, or Supabase Auth and shared database persistence.
- Refresh buttons and pull-to-refresh for fetching other members' changes.

Photo uploads, private messaging, connection requests, event RSVPs, and moderation
are not implemented yet. A meetup suggestion is a post, not an event booking.
Legacy guide/marketplace screens remain in the repository for future reuse but
are not part of the main community navigation.

## Development

Flutter 3.47.2 / Dart 3.13.2. Android CI uses Java 17.

```powershell
flutter analyze
flutter test
flutter build web --release
flutter build apk --release
```

The new community UI is in `lib/features/community/community_app.dart` and its
data layer is `lib/state/community_store.dart`. Shared styling is in
`lib/theme/app_theme.dart`. Supabase migrations are in `supabase/migrations`.
Use `package:material_ui/material_ui.dart` consistently for Material widgets.

## Automated builds

GitHub Actions checks code, runs tests, and builds Android and web on pushes,
pull requests, or manual runs. Find downloads in Actions > Automated build >
the successful run > Artifacts. Artifacts are retained for 14 days. Android APKs
use the existing test signing configuration, not store release signing.

Repository variables `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` connect built
apps to your hosted project. Leave both empty for local-demo builds. Never use
secret/service-role keys. These workflows create downloads; they do not publish
the Android app or host the Supabase backend. On main, the workflow also deploys
the built web app to GitHub Pages once Settings > Pages > Source is set to
GitHub Actions. See the setup guide for details.
