# Implementation audit — 9 October 2026

This audit is based on source inspection and executable checks, not screenshots.

## Findings and implementation

| Area | Initial finding | Current implementation |
| --- | --- | --- |
| Add/edit/delete | Existing doctor and visit forms, independent visit IDs and SQLite writes | Preserved; exact clinical text is no longer trimmed on save. Required-field validation still rejects blank input. Delete confirmation and unsaved changes protection retained. |
| Relationships | Multiple visits already referenced one doctor by ID | Preserved. Editing/deleting one visit does not change its sibling. Doctors with visits cannot be deleted. |
| Persistence | Version 1 SQLite database | Additive version 2 migration; same application ID and database path. No table replacement, seed records or destructive reset. |
| Home | Large slogan and metric cards | Greeting/date, Add Visit, compact derived totals, latest visit and explicitly recorded follow-up date. Local/cloud status is secondary. |
| History | Inline filters; state lost across tabs | Search, compact Add action, bottom-sheet doctor/date/medicine/test filters, removable chips, dated timeline. Search/filter/scroll state retained across navigation. |
| Doctors | Large cards | Searchable initials list with specialty, facility and derived visit counts. |
| Reports | Tests only; no attachment storage | PDF/PNG/JPEG/WebP files copied into private persistent storage and linked to a visit or stable test ID. Image preview, external opening, removal confirmation and missing-file errors. |
| Settings | Technical account wording | Compact grouped local-data, account-sync and Google Drive rows with truthful Not connected status. |
| Follow-up | No field | Optional user-recorded date. No inferred date or reminder claim. |

## Attachment guarantees and limits

- File contents are copied and flushed before attachment metadata is committed; temporary picker paths are not persisted.
- Generated filenames are restricted to the app's attachment directory. Source files are never removed. Imports validate supported signatures and enforce a 25 MB limit.
- Failed metadata writes roll back the copied file when possible. A process killed between copying and committing can leave an unreferenced private file; orphan-file maintenance is not yet implemented.
- Test IDs remain stable through renaming/reordering. Removing a test retains its documents on the parent visit.
- Explicit attachment or visit deletion queues owned-file cleanup transactionally. Failed cleanup is retried on startup/later writes.
- A missing file produces a user-facing error without silently deleting its record. PDF opening requires an installed compatible viewer; viewer failures are reported honestly.

## Verification evidence

- Baseline: six existing host tests passed before the refinement.
- Real SQLite migration test: version 1 raw records remain unchanged, including Unicode, spaces and line breaks. Two independent visits remain associated with one doctor.
- Separate-process test: stored doctors, visits, attachment metadata and PNG/PDF bytes are read from disk after repository shutdown and source-file deletion.
- Repository tests: isolated edits/deletes, stable test links, deleted-test reparenting, foreign keys, failed saves, file validation and durable cleanup.
- UI tests: add doctor → two visits → details → edit/delete; untouched clinical text; retained History search/filter state; attachment import/cancel/open/remove/missing-file feedback; 360-pixel layouts with 200% text.
- The 200% text checks exposed header/toolbar overflows, which were corrected with adaptive stacking/wrapping.
- `flutter analyze --no-pub`: **passed, no issues found**.
- The preview UI test accepts a retained Windows file only when deletion fails with OS sharing-violation code 32 and the filename is present in the cleanup queue. The storage tests separately verify successful queued deletion after reopening.
- `flutter test --no-pub --concurrency=1`: **13 tests passed** in the final complete run.
- `flutter build apk --debug --no-pub --target-platform android-arm64`: **passed**. [Journal debug APK](../build/verified/my-medical-history-journal-arm64-debug.apk), 116,107,780 bytes (about 110.7 MiB). Package identity verified as `com.datawithumerz.my_medical_history`, version 1.0.0; this is the normal app entry point, not the verification package.
- APK SHA-256: `95364FB62553CE38478EB36CCDD4CC849C25F212EAA9699C5538CD37B8E272A4`.

## Incomplete and unverified

**Incomplete:** Supabase authentication/account sync and Google Drive OAuth/backup/restore are separate integration tasks. Neither is configured or simulated. Export/sharing, reminders, doctor photos, account profile, desktop/web persistence and iOS device validation remain outside this implementation.

**Native runtime unverified:** the Android phone was connected during setup but is currently absent from ADB. Device tests use an opt-in `.verification` package plus a dedicated database/files directory; no user journal was cleared, seeded or uninstalled. Native picker selection, external PDF-viewer handoff and Android force-stop/restart persistence still need device execution. Host interface tests are not substitutes for those native checks.

**Build environment, resolved for Android:** installed missing Android SDK 35 (and Gradle installed SDK 34 and CMake 3.22.1). Disabled Kotlin incremental caching after the file-picker plugin hit a Windows incremental-cache failure. Windows plugin symlinks may require Developer Mode; resolved dependencies allow the current checks to run with `--no-pub`. The final Android build succeeded.
