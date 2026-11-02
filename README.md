# Skill Sprout

A hobby app that combines a guide, a forum, and a marketplace. Users pick their hobbies and set a skill level for each. Beginners get a step-by-step guide to the basics. Advanced and Pro members answer beginner questions. Anyone can list gear or materials to **sell, trade, lend, or give away**.

> **Status:** UI foundation only. All data is mock data in memory, and sign-in is simulated (any email plus a password of 6+ characters). The backend, messaging, and posting threads are not built yet.

## Features (current)

- **Sign in** (mock) and **onboarding**: choose hobbies and a level for each (Beginner / Intermediate / Advanced / Pro)
- **Home**: your hobby cards with guide progress or open questions, fresh listings, and a thread feed from your hobbies
- **Hobby page**: a **Guide** tab (checkable basics) or a **Mentor** tab (open questions) depending on your level, plus **Discussion** and **Listings** tabs
- **Market**: search, a hobby filter, type filters, listing detail pages, and a create-listing form
- **Profile**: your hobbies and levels, your listings, sign out

## Getting started

Requires Flutter 3.47+ (Dart 3.13+).

```sh
flutter pub get
flutter run            # pick a device, e.g. -d chrome or an emulator
```

Notes:
- The fonts (Fraunces, DM Sans) come from `google_fonts` and download on first launch, so that launch needs internet.
- **Windows desktop** builds require Windows **Developer Mode** (for plugin symlinks). Android, iOS, and web builds don't.

## Automated builds

GitHub Actions runs `.github/workflows/build.yml` on every push and pull request.
You can also start it from **Actions → Automated build → Run workflow**.
It uses Flutter 3.47.2 (Dart 3.13.2) and Java 17, installs the locked dependencies,
runs `flutter analyze` and `flutter test`, then builds a release Android APK and
a release web app. A failed check or test stops the build.

To download a successful build, open **Actions → Automated build**, select the
run, and scroll to **Artifacts**:

- **skill-sprout-android** contains `app-release.apk` for Android testing.
- **skill-sprout-web** contains the web files to serve with a web server.

Downloads are kept for 14 days. The APK currently uses the project's debug
signing key; store publishing requires a separate release signing configuration.
This workflow builds the app; it does not deploy it or publish it to an app store.
When upgrading Flutter, update the version in the workflow along with the project.

## Project structure

```
lib/
  main.dart, app.dart     entry point, MaterialApp, AppScope
  theme/                  colors, radii, ThemeData (AppTheme.light)
  models/                 Hobby, SkillLevel, Listing, ListingType, Post
  data/mock_data.dart     placeholder hobbies, posts, listings
  state/app_state.dart    AppState (ChangeNotifier) + AppScope (InheritedNotifier)
  routing/routes.dart     fade-through route, snackbar helper, timeAgo
  widgets/                shared UI components
  features/               auth, onboarding, shell, home, hobby, market, profile
test/
  app_state_test.dart     state logic unit tests
  smoke_test.dart         full click-through at phone size (fails on layout overflows)
```

## Conventions

- **Import `package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.** The `animations` and `google_fonts` packages are built on `material_ui`, and mixing the two libraries causes type mismatches.
- State is read with `AppScope.of(context)` in `build` and `AppScope.read(context)` in callbacks. `AppState` is where the backend will plug in later.
- Use plain `MaterialPageRoute`. The theme already applies a shared-axis transition.
- Reuse the components in `lib/widgets/` and the colors in `AppColors` rather than hard-coding styles.
- Before pushing, run `flutter analyze` and `flutter test`.

## Tech

Flutter · [`animations`](https://pub.dev/packages/animations) · [`google_fonts`](https://pub.dev/packages/google_fonts) · [`material_ui`](https://pub.dev/packages/material_ui)
