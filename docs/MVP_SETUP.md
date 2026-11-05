# Skill Sprout: class demo and shared backend

## Run now, without an account or server

Open the project in VS Code, then Terminal > New Terminal:

```powershell
flutter pub get
flutter run -d chrome --web-port 5173
```

Choose a display name and Enter demo. This is explicitly labeled LOCAL DEMO.
Profiles, community memberships, posts, and replies are stored on this device.
Keep the same browser and port when restarting to retain browser data.
Demo names are identities, not authenticated accounts. Never use private data.
Demo content is separate from Supabase and is not uploaded when you connect.

## Five-minute presentation journey

1. Enter demo as Abigail.
2. Open Communities > Crochet > Join community.
3. Select New post; add a title and message; Publish post.
4. Go back to the main screen and open Profile > Switch demo member.
5. Enter demo as Jordan; join Crochet; open Abigail's post and Send reply.
6. Switch back to Abigail; open the post to show the reply.
7. Restart on the same browser/port to demonstrate saved data.

The hosted version uses separate real accounts and works across devices.
Use Refresh community or Refresh replies to retrieve another user's changes.
This MVP does not yet have automatic live updates, photo uploads, private chat,
connection requests, event RSVPs, or reporting/moderation. Meet up is a post type,
not a scheduled event system. Legacy marketplace and guide files are retained
for reference but are not linked into the community MVP.

## Connect Supabase

1. Create a free project at https://supabase.com/dashboard. Choose a region
   near your team. Keep the database password private.
2. In SQL Editor, create a new query, paste the entire contents of
   `supabase/migrations/202611040001_community_mvp.sql`, and run it once.
   Use a new project: this migration intentionally does not replace existing tables.
3. From the project Connect dialog or API settings, copy the project URL and
   publishable key (the legacy anon key also works). Never use a secret or
   service-role key in Flutter or in GitHub build variables.
4. Copy `supabase.example.json` to `supabase.local.json` and fill in those two
   values. The local file is ignored by Git.
5. Stop Flutter and start the connected app:

```powershell
flutter run -d chrome --web-port 5173 --dart-define-from-file=supabase.local.json
```

6. Choose Create account and register with a real email address. If email
   confirmation is enabled, confirm the email and return to Sign in.
   Use the Supabase Auth URL Configuration to set the local Site URL to
   `http://localhost:5173`. For a hosted web demo, use its actual address.
7. Register a second account in another browser or device, join the same
   community, post a reply, then refresh on the first device.

### Launch from VS Code

Install the Flutter extension if needed. Open Run and Debug (`Ctrl+Shift+D`),
choose **Skill Sprout: Supabase**, and press F5. The **local demo** launch option
works without configuring a backend. Stop the current run before switching.
The local configuration template has already been copied to `supabase.local.json`;
replace both placeholders before using the Supabase launch option.

### Confirm the setup worked

- The app offers Sign in / Create account and no longer shows LOCAL DEMO.
- Table Editor shows `hobbies`, `profiles`, `memberships`, `community_posts`,
  and `community_comments`. The hobbies table has eight entries.
- After registration, Authentication > Users shows the account and `profiles`
  contains its display name. Do not manually add passwords to any table.
- Joining a hobby creates a membership; publishing and replying create rows
  in the corresponding tables.
- With two real accounts, a reply becomes visible to the other account after
  Refresh replies. A different browser alone does not share local-demo data.

If email confirmation does not arrive, check the spam folder and Authentication
logs before retrying. If posting fails, confirm you joined the community and
ran the full SQL script successfully. Do not rerun the migration against an
already initialized database; send the error message for help instead.

### Push this MVP to GitHub

The commit includes the app, fonts and licenses, database migration, tests,
VS Code launch options, and automated builds. It excludes generated builds
and your ignored `supabase.local.json`.

In VS Code Source Control, use **Push** or **Sync Changes** to upload local
commits. Alternatively, from the project terminal:

```powershell
git push origin main
```

Then open GitHub > Actions > Automated build and check the new run. Your team
can pull the commit, copy the example configuration into their own ignored
local file, and connect to the same project using its URL and publishable key.
App members create their own accounts; teammates do not need the database
password to run the app. Invite dashboard collaborators separately if needed.

The SQL creates profiles automatically on signup, uses Supabase Auth, and
restricts profile edits and memberships to their owner. All signed-in members
can read community posts; only joined members can create posts and replies.
Neither email addresses nor passwords are stored in public profile tables.

## Build for class

Local demo APK:

```powershell
flutter build apk --release
```

Connected APK:

```powershell
flutter build apk --release --dart-define-from-file=supabase.local.json
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.
For web, replace `apk` with `web`; serve `build/web` using a web server.
An APK built without configuration is always the local demo.

## GitHub automatic builds

In repository Settings > Secrets and variables > Actions > Variables, add
`SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. These are client configuration,
not privileged server keys. With both variables set, builds connect to Supabase.
With neither set, builds use the local demo. Partial configuration fails CI.
Pull requests from forks build the local demo because repository variables
may be unavailable. Tests always use an isolated in-memory demo store.

## Team handoff

- Person 1: profiles and a people directory; use `profiles` and Supabase Auth.
- Person 2: project photos and feed polish; extend `community_posts` and add
  a Storage bucket with owner-only upload rules.
- Person 3: integration, tests, presentation preparation; private messaging only
  after the core demonstration works reliably.

Community data lives in `lib/state/community_store.dart`; screens are in
`lib/features/community/community_app.dart`; shared styling lives in
`lib/theme/app_theme.dart`. Keep future database changes in new migration files.
