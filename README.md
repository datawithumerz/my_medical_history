# My Medical History

A local personal medical journal built with Flutter: warm off-white surfaces, navy text, teal actions and dated visit timelines. Existing records stay in the same SQLite database; there is no sample account or seed data.

## Run

```sh
flutter pub get
flutter run -d <android-device-id>
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64
```

The attachment picker requires Android SDK platform 35 alongside Flutter's compile SDK. On Windows, plugin symlinks may require Developer Mode. Once dependencies are resolved, `--no-pub` runs checks and Android builds without repeating Windows plugin-link creation. Android/iOS use `sqflite`; desktop/web storage adapters are not implemented.

## Implemented

- Home, Doctors, History, Reports and Settings, with helpful empty states.
- Compact greeting/date, Add Visit, latest visit, explicit recorded follow-up and counts derived from saved records.
- Searchable doctors with initials, specialty, facility and visit count. Add/edit doctors; deletion is blocked while a doctor has visits.
- Independent visits per doctor, with date/time, reason and optional diagnosis, notes, facility, medicines, tests and follow-up date. Follow-up dates do not schedule reminders.
- Visit details, edit, delete confirmation and unsaved-form protection. Clinical text is saved exactly as entered, including whitespace.
- History text search and combined doctor/date/medicine/test filters in a bottom sheet. Active chips and state survive details and tab changes.
- Image/PDF attachments linked to visits or individual tests. Selected bytes are copied into persistent app storage before metadata is saved. PNG/JPEG/WebP previews and external PDF opening; removal confirmation and missing-file feedback. Files are limited to 25 MB.
- Separate account-sync and Google Drive-backup boundaries; both show **Not connected**.

## Data preservation

[SQLite schema version 2](lib/data/sqlite_medical_repository.dart) adds follow-up and attachment metadata without replacing existing tables or rewriting clinical text. Existing test entries receive deterministic identities when loaded; subsequent edits preserve those identities. Removing a test moves its attachment links to the visit rather than deleting the files.

The app keeps its original Android application ID and `medical_history.db` filename. Updates use SQL UPDATE/INSERT, not destructive REPLACE. Doctor relationships use restrictive foreign keys; visit deletion removes its attachment metadata and queues only owned files for deletion. Failed file cleanup is retried on startup or later writes. Picker source files are never deleted.

Data lives in private app storage and is not additionally encrypted by this app. Android automatic backup is disabled. Uninstalling or clearing storage removes local records. A failed database open offers retry and never resets the database.

## Verification

See [the implementation audit](docs/IMPLEMENTATION_AUDIT.md) for implemented, incomplete and unverified findings and the latest build/device results.

Host tests exercise the real SQLite migration and a separate Dart process, exact clinical text, two visits under one doctor, isolated editing/deletion, attachment byte persistence, source-file deletion, test-link stability, failed writes, filters, UI attachment actions and 200% text layouts.

Android tests must run in order. Use the opt-in verification package to keep device tests separate from the user's app:

```powershell
$env:ORG_GRADLE_PROJECT_journalVerification = 'true'
flutter test --no-pub integration_test/core_flow_test.dart -d <android-device-id>
flutter test --no-pub integration_test/restart_test.dart -d <android-device-id>
Remove-Item Env:ORG_GRADLE_PROJECT_journalVerification
```

The first test uses `core_flow_test.db`, exercises add/edit/delete and retains a visit with PNG/PDF copies. The second starts a new process, checks the records and file bytes, opens the image preview and removes only its fixtures. Never run destructive reset/uninstall commands against the normal app to make tests pass. Rebuild the normal app after integration tests because they change the APK entry point.

## Structure and remaining integrations

- [Domain](lib/domain): immutable records and History filtering.
- [Data](lib/data): repository contract and versioned SQLite adapter.
- [State](lib/state): derived lists/counts and mutation orchestration.
- [Services](lib/services): managed attachments, picker/viewer adapters, separate cloud boundaries.
- [UI](lib/ui): shared journal theme, forms, timeline rows and screens.

Supabase authentication/account sync (including conflict handling) and Google OAuth/Drive backup/restore are separate unfinished integrations. There are no simulated successes. Export/sharing, notifications, doctor photos/maps/calling, profile management, desktop/web persistence and iOS validation are also unfinished. No current-medication status, diagnoses or health insights are inferred.

The Gradle heap is capped at 2 GB with two workers for this development machine.
