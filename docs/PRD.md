# My Medical History — Product Requirements Document

**Document:** `PRD.md`  
**Version:** 1.0 (consolidated requirements baseline)  
**Date:** 2026-10-15  
**Status:** Requirements defined; implementation status **not assessed**  
**Target:** Flutter mobile application; Android first, iOS later  
**Audience:** University reviewers, product stakeholders, Flutter developers, QA engineers, and AI coding agents

> **Status disclaimer:** P0/P1/P2 denote requirement priority, not implementation status. Nothing in this document is evidence that a feature has been built. Implementation status must be established through a source-code audit and tests.

## 1. Product overview and vision

**Product name:** My Medical History  
**Product type:** Personal medical records management / personal medical record vault  
**Primary users:** Individuals and patients organizing their own medical history.

My Medical History is a secure, offline-first mobile application in which users can record and retrieve medical visits, doctors, hospitals, symptoms, diagnoses, medicines, tests, prescriptions, reports, notes, photos, locations, and follow-ups. Doctor profiles are reusable; each visit remains a separate historical record. Records are stored locally and can be backed up and restored securely through the user's own Google Drive.

### 1.1 Problem statement

Patients can lose paper prescriptions, forget medicines and past diagnoses, misplace laboratory reports, or lack a reliable medical history when returning to a doctor. This product provides a structured, searchable personal record of that information.

### 1.2 Product boundaries

This is **not** a hospital management system, clinician EHR, electronic prescribing service, or diagnostic decision-making tool. The application stores user-entered medical information and must not invent diagnoses, test interpretations, or prescriptions. Optional OCR is an assistive capture feature, not clinical verification.

### 1.3 Product goals

| ID | Goal |
|---|---|
| G-01 | Digitize personal medical history |
| G-02 | Organize records by doctor, hospital, and visit |
| G-03 | Preserve all previous medical visits |
| G-04 | Support medicines, diagnoses, tests, and documents |
| G-05 | Make medical history searchable and filterable |
| G-06 | Work without an internet connection |
| G-07 | Back up and restore records using Google Drive |
| G-08 | Protect sensitive medical information |
| G-09 | Provide a simple interface for non-technical users |
| G-10 | Allow users to update and correct historical records |

## 2. Requirement interpretation and priority conventions

- **P0:** Essential MVP capability.
- **P1:** Important for the first complete release.
- **P2:** Future enhancement.
- **Product requirement:** Defines observable behavior or quality; technology choices are not implied unless explicitly stated.
- **Proposed implementation:** Architecture, packages, data structures, and design approaches that developers may refine while meeting product behavior.
- **Acceptance:** A feature is accepted only after code and test evidence confirm it works. Requirements alone do not prove completion.

Requirement identifiers FR-001 through FR-149 are retained as originally assigned. Where requirements overlap, both IDs remain for traceability.

## 3. User journeys

### 3.1 First-time onboarding and setup

1. Open splash/onboarding and learn the app's purpose.
2. Continue offline or sign in with Google.
3. Separately opt into Google Drive access; permission is not assumed from Google sign-in.
4. Optionally restore an existing backup.
5. Arrive at the dashboard, with clear connection/backup status.

### 3.2 First visit to a new doctor

1. Choose **Add Medical Visit**.
2. Create a doctor profile or select an existing doctor.
3. Choose or add hospital/clinic, including address and optionally photo and map pin.
4. Enter visit date/time, reason, symptoms, diagnosis, and notes.
5. Add zero or more prescribed medicines and tests.
6. Capture or attach prescriptions, test reports, and other images/PDFs.
7. Review and save locally, including while offline.
8. When authorized and connectivity permits, back up the saved data to Google Drive.

### 3.3 Return to the same doctor

1. Search/open the existing doctor profile.
2. Review earlier visits chronologically.
3. Select **Add New Visit**.
4. Reuse doctor information; choose the relevant hospital for this visit.
5. Save a distinct visit record. Earlier visits must not be overwritten.

### 3.4 Locate and update past information

1. Search by doctor, hospital, diagnosis, symptom, medicine, or test; optionally filter by date.
2. Open a matching visit and view its medicines, tests, attachments, and notes.
3. Edit the relevant record, add a later report, or export/share selected data.
4. Preserve the historical visit identity and original visit date unless explicitly edited.

### 3.5 Backup, device replacement, and recovery

1. Connect a Google account and explicitly grant Drive access.
2. Create a validated, encrypted backup including structured data and attachments.
3. On another device, sign in/connect Drive and select restore.
4. Validate backup integrity before restoring; avoid silent data loss or corruption.
5. Allow disconnection without unexpected deletion of locally saved records.

## 4. Functional requirements

### 4.1 Authentication and onboarding

| ID | Requirement | Priority |
|---|---|---|
| FR-001 | Display splash screen | P1 |
| FR-002 | Show onboarding screens | P1 |
| FR-003 | Allow users to continue offline without Google login | P0 |
| FR-004 | Support Google account sign-in | P0 |
| FR-005 | Request Google Drive access separately | P0 |
| FR-006 | Allow users to skip Drive setup | P0 |
| FR-007 | Display connected Google account | P1 |
| FR-008 | Allow account disconnection | P1 |
| FR-009 | Support first-time backup restoration | P0 |

### 4.2 Dashboard

| ID | Requirement | Priority |
|---|---|---|
| FR-010 | Display personalized home screen | P0 |
| FR-011 | Show total doctors | P0 |
| FR-012 | Show total visits | P0 |
| FR-013 | Show total medicines recorded | P1 |
| FR-014 | Show total reports | P1 |
| FR-015 | Display recent medical visits | P0 |
| FR-016 | Provide Add Visit action | P0 |
| FR-017 | Display upcoming follow-ups | P1 |
| FR-018 | Show backup/sync status | P1 |
| FR-019 | Provide global search entry | P0 |

### 4.3 Doctor management

| ID | Requirement | Priority |
|---|---|---|
| FR-020 | Add doctor | P0 |
| FR-021 | Edit doctor information | P0 |
| FR-022 | Delete/archive doctor with confirmation | P1 |
| FR-023 | Save doctor name | P0 |
| FR-024 | Save specialization | P1 |
| FR-025 | Save phone number | P0 |
| FR-026 | Save doctor photo | P1 |
| FR-027 | Save optional notes | P1 |
| FR-028 | Associate doctor with hospital/clinic | P0 |
| FR-029 | Show doctor-wise visit history | P0 |
| FR-030 | Add new visit under existing doctor | P0 |
| FR-031 | Search and filter doctors | P0 |
| FR-032 | Call doctor from profile | P1 |
| FR-033 | Detect possible duplicate doctor profiles | P2 |

### 4.4 Hospital and location management

| ID | Requirement | Priority |
|---|---|---|
| FR-034 | Add hospital/clinic | P0 |
| FR-035 | Edit hospital information | P0 |
| FR-036 | Save hospital name | P0 |
| FR-037 | Save address | P0 |
| FR-038 | Save hospital photo | P1 |
| FR-039 | Save hospital contact number | P1 |
| FR-040 | Capture current GPS location | P1 |
| FR-041 | Manually select map pin | P1 |
| FR-042 | Save latitude and longitude | P1 |
| FR-043 | Open saved location in Google Maps | P1 |
| FR-044 | Associate multiple doctors with a hospital | P1 |
| FR-045 | Select hospital for each visit | P0 |

### 4.5 Medical visit management

| ID | Requirement | Priority |
|---|---|---|
| FR-046 | Create new medical visit | P0 |
| FR-047 | Select existing doctor | P0 |
| FR-048 | Add new doctor during visit creation | P0 |
| FR-049 | Select hospital/clinic | P0 |
| FR-050 | Record visit date and time | P0 |
| FR-051 | Record reason for visit | P0 |
| FR-052 | Record symptoms | P0 |
| FR-053 | Record diagnosis | P0 |
| FR-054 | Record treatment instructions | P1 |
| FR-055 | Record doctor's notes | P1 |
| FR-056 | Set follow-up date | P1 |
| FR-057 | Save visit as draft | P1 |
| FR-058 | Edit saved visit | P0 |
| FR-059 | Delete visit with confirmation | P0 |
| FR-060 | Display complete visit details | P0 |
| FR-061 | Maintain chronological history | P0 |
| FR-062 | Preserve past visits when adding new ones | P0 |
| FR-063 | Show created/updated timestamps | P1 |
| FR-064 | Maintain edit history for important changes | P2 |

### 4.6 Medicine management

| ID | Requirement | Priority |
|---|---|---|
| FR-065 | Add multiple medicines to visit | P0 |
| FR-066 | Record medicine name | P0 |
| FR-067 | Record strength/dosage | P0 |
| FR-068 | Record frequency | P0 |
| FR-069 | Record treatment duration | P0 |
| FR-070 | Record administration instructions | P1 |
| FR-071 | Record start/end dates | P1 |
| FR-072 | Edit/delete medicine entry | P0 |
| FR-073 | View medicines prescribed in a visit | P0 |
| FR-074 | Search medicine history across visits | P1 |
| FR-075 | Distinguish historical prescriptions from current medicines | P1 |
| FR-076 | Set optional medication reminders | P2 |

### 4.7 Medical tests and reports

| ID | Requirement | Priority |
|---|---|---|
| FR-077 | Add multiple tests per visit | P0 |
| FR-078 | Record test name | P0 |
| FR-079 | Record test date | P0 |
| FR-080 | Track test status (recommended, scheduled, completed) | P1 |
| FR-081 | Record result/summary | P0 |
| FR-082 | Attach laboratory report | P0 |
| FR-083 | Support PDF files | P0 |
| FR-084 | Support JPG/PNG images | P0 |
| FR-085 | View report details | P0 |
| FR-086 | Search reports by name/date | P1 |
| FR-087 | Edit/delete test records | P0 |
| FR-088 | Allow reports to be added after visit completion | P0 |

### 4.8 Prescriptions and attachments

| ID | Requirement | Priority |
|---|---|---|
| FR-089 | Capture prescription using camera | P0 |
| FR-090 | Select image from gallery | P0 |
| FR-091 | Import PDF documents | P0 |
| FR-092 | Attach multiple files to a visit | P0 |
| FR-093 | Preview attachments | P0 |
| FR-094 | Rename/describe attachments | P1 |
| FR-095 | Replace or remove attachment | P0 |
| FR-096 | Store attachments offline | P0 |
| FR-097 | Associate attachments with doctors, visits, or tests | P1 |
| FR-098 | Export/share selected document | P1 |
| FR-099 | Extract text from prescriptions using OCR | P2 |

OCR-generated content must be verified by the user and not treated as confirmed medical advice.

### 4.9 Medical history, search, and filters

| ID | Requirement | Priority |
|---|---|---|
| FR-100 | Display complete medical history timeline | P0 |
| FR-101 | Display doctor-wise visit history | P0 |
| FR-102 | Search by doctor | P0 |
| FR-103 | Search by hospital | P0 |
| FR-104 | Search by diagnosis | P0 |
| FR-105 | Search by symptoms | P1 |
| FR-106 | Search by medicine | P1 |
| FR-107 | Search by test name | P1 |
| FR-108 | Filter by date range | P0 |
| FR-109 | Filter by doctor/hospital | P0 |
| FR-110 | Combine multiple filters | P1 |
| FR-111 | Sort newest/oldest first | P0 |
| FR-112 | Clear search filters | P0 |
| FR-113 | Open matching record directly | P0 |

### 4.10 Google Drive backup and synchronization

| ID | Requirement | Priority |
|---|---|---|
| FR-114 | Connect Google Drive account | P0 |
| FR-115 | Request minimum required Drive permissions | P0 |
| FR-116 | Create app-specific backup storage | P0 |
| FR-117 | Encrypt backup before upload | P0 |
| FR-118 | Back up structured medical records | P0 |
| FR-119 | Back up photos, PDFs, and attachments | P0 |
| FR-120 | Provide manual Backup Now | P0 |
| FR-121 | Restore backup to a new device | P0 |
| FR-122 | Display last successful backup time | P0 |
| FR-123 | Display backup progress and failures | P1 |
| FR-124 | Support automatic background backup when permitted | P1 |
| FR-125 | Retry interrupted uploads | P1 |
| FR-126 | Detect changes since last backup | P1 |
| FR-127 | Handle multiple-device conflicts safely | P2 |
| FR-128 | Provide backup version/recovery options | P1 |
| FR-129 | Support account disconnect without deleting local data | P1 |

**Boundary:** Backup/restore is a first-release requirement; reliable bidirectional multi-device synchronization and conflict resolution are a separate P2 enhancement. The app must not label a backup as multi-device live sync unless it actually provides that behavior.

### 4.11 Security and privacy

| ID | Requirement | Priority |
|---|---|---|
| FR-130 | Encrypt sensitive local records and files | P0 |
| FR-131 | Encrypt Google Drive backups | P0 |
| FR-132 | Store authentication tokens securely | P0 |
| FR-133 | Require explicit permission for camera/location/files | P0 |
| FR-134 | Provide privacy notice | P0 |
| FR-135 | Allow user to delete personal records | P0 |
| FR-136 | Provide optional app PIN | P1 |
| FR-137 | Support biometric unlock | P1 |
| FR-138 | Lock app after inactivity | P1 |
| FR-139 | Provide account and backup disconnection controls | P1 |
| FR-140 | Allow user to delete backups separately | P1 |
| FR-141 | Provide secure recovery of encrypted backups | P0 |

### 4.12 Notifications and export

| ID | Requirement | Priority |
|---|---|---|
| FR-142 | Schedule follow-up reminders | P1 |
| FR-143 | Show upcoming appointments | P1 |
| FR-144 | Allow notification preferences | P1 |
| FR-145 | Export individual visit summary as PDF | P1 |
| FR-146 | Export complete medical history | P1 |
| FR-147 | Share selected medical records | P1 |
| FR-148 | Import a previously exported backup | P1 |
| FR-149 | Generate doctor-wise history summaries | P2 |

## 5. Non-functional requirements

| Category | Requirement / quality expectation |
|---|---|
| Performance | Common navigation and local record retrieval should feel responsive; target under 2 seconds on supported devices |
| Availability | Core record management operates without network connectivity |
| Reliability | No silent loss of records or attachments |
| Data integrity | Use transactional updates and enforce referential integrity |
| Security | Encrypt sensitive data at rest; protect credentials and backup keys |
| Privacy | No third-party sharing without user authorization |
| Usability | Clear labels, predictable navigation, straightforward forms |
| Accessibility | Readable contrast, scalable text, accessible controls and touch targets |
| Compatibility | Define and test supported Android versions before release; iOS later |
| Scalability | Support thousands of visits and documents |
| Backup | Detect incomplete/corrupt backups before restore |
| Recovery | Restore structured data **and** attachments after device replacement |
| Maintainability | Modular, testable Flutter code and explicit separation of concerns |
| Testing | Unit, widget, integration, security, backup, and restore tests |

## 6. Business rules and invariants

1. **One doctor, many visits:** A new visit must never overwrite a previous visit.
2. **One hospital, many doctors:** Hospital information is reusable; doctors may work at multiple hospitals.
3. **Independent visit records:** Each visit has its own date, diagnosis, medicines, tests, and attachments.
4. **Historical accuracy:** Changes to a doctor's current contact details must not rewrite past medical facts.
5. **Incomplete visits permitted:** A visit can be saved before diagnosis, medicine, or test information is known.
6. **User ownership:** Users control their personal records and authorized backup access.
7. **Safe deletion:** Removing a doctor must not silently destroy associated historical visits.
8. **Offline-first:** Local saves cannot depend on network access.
9. **Backup integrity:** Validate backups before restoration or replacing local data.
10. **No medical assumptions:** Do not invent clinical information or treat OCR as verified clinical instructions.

### 6.1 Data handling constraints

- Store stable identifiers for records so editing and future synchronization can reference the same record.
- Record timestamps for creation and modification where required.
- Preserve the relationship between a visit and its doctor/hospital even if current profile information changes.
- Require explicit confirmation for destructive actions and avoid cascading deletion of history without user understanding.
- Treat prescriptions, reports, images, and locations as sensitive user data.

## 7. Data model expectations

The following are **conceptual entities and expected attributes**, not a frozen physical database schema. Developers may normalize or expand the schema while preserving behavior and referential integrity.

| Entity | Expected core attributes / relationships |
|---|---|
| User | id, name, email, created_at |
| Doctor | id, user_id, name, specialization, phone, photo_path, optional notes |
| Hospital | id, user_id, name, address, latitude, longitude, photo_path, optional phone |
| DoctorHospital | doctor_id, hospital_id; many-to-many affiliation |
| Visit | id, doctor_id, hospital_id, date/time, reason, symptoms, diagnosis, treatment instructions, notes, follow_up_date, created_at, updated_at |
| Medicine | id, visit_id, name, strength, dose, frequency, duration, instructions, optional start/end dates |
| MedicalTest | id, visit_id, name, date, status, result/summary |
| Attachment | id, visit_id, optional test_id, type, file_path, mime_type, optional description; model must also accommodate doctor-linked attachments (FR-097) |
| Reminder | id, visit_id, scheduled_at, status |
| BackupMetadata | id, version, created_at, status, checksum; linkage to backup storage |

### 7.1 Relationship expectations

- User **1:N** Doctor, Hospital, and Visit ownership (directly or through parent relationships).
- Doctor **1:N** Visit.
- Hospital **1:N** Visit.
- Doctor **N:M** Hospital through DoctorHospital.
- Visit **1:N** Medicine, MedicalTest, and Attachment.
- MedicalTest **0:N** Attachment (as applicable).
- Visit **0:N** Reminder.
- A doctor profile may have attachments, independently of visit attachments, as required by FR-097.

### 7.2 Implementation considerations (proposed, not mandatory schema)

Use UUID-style stable IDs, indexed foreign keys, transactional writes, explicit deletion policies, schema migrations, and an attachment metadata table separate from binary file storage. The exact fields, indexes, encryption method, and migrations require technical design and source-code review.

## 8. Screen inventory and navigation expectations

| # | Screen | Purpose |
|---|---|---|
| 1 | Splash | App initialization |
| 2 | Onboarding | Introduce app |
| 3 | Welcome / Sign-in | Start offline or connect Google |
| 4 | Google Drive Setup | Configure backup |
| 5 | Home | Dashboard |
| 6 | Doctors | Doctor directory |
| 7 | Add/Edit Doctor | Manage doctor |
| 8 | Doctor Profile | Doctor information and visit history |
| 9 | Hospitals | Hospital directory |
| 10 | Add/Edit Hospital | Hospital and map location |
| 11 | Medical History | Complete timeline |
| 12 | Visit Details | View saved visit |
| 13 | Select Doctor | Existing/new doctor |
| 14 | Visit Form | Symptoms, diagnosis, date |
| 15 | Medicine Form | Add prescribed medicines |
| 16 | Test Form | Add tests/results |
| 17 | Attachments | Capture/upload documents |
| 18 | Review Visit | Confirm before saving |
| 19 | Reports | Browse medical reports |
| 20 | Report Viewer | Open PDF/image |
| 21 | Medicines | Medicine history |
| 22 | Search | Global search |
| 23 | Filters | Advanced filtering |
| 24 | Follow-ups | Scheduled follow-up visits |
| 25 | Settings | App configuration |
| 26 | Backup & Restore | Manage Drive backups |
| 27 | Security | PIN/biometrics |
| 28 | Profile | Personal settings |

These are **28 conceptual screens**, not a mandate for 28 separate routes: some may be dialogs, sheets, or steps in a guided workflow. The earlier Google Stitch design direction calls for a clean healthcare UI with clear typography, spacious forms, rounded cards, accessible touch targets, and blue/white styling. Its proposed five-tab bottom navigation is **Home, Doctors, History, Reports, Settings**. Medicines may be accessible through the dashboard or other navigation; this is a UX layout choice, not an added product feature.

## 9. Proposed implementation architecture (not product requirements)

The established direction is Flutter/Dart with an offline-first local database and Google Drive used for secure backup/restore rather than as a live transactional database.

```text
Flutter UI
  ├── Home / Doctors / Hospitals / Visits
  ├── Medicines / Tests / Reports / Search
  └── Settings / Backup / Security
        ↓
Application / business logic
  ├── Doctor & hospital management
  ├── Visit, medicine, test, attachment management
  ├── Search, filters, reminders
  └── Backup / restore and security
        ↓
Repository / persistence
  ├── Local relational database (SQLite proposed)
  ├── Encrypted local attachment storage
  └── Secure credential/key storage
        ↓
Optional integrations
  ├── Google Sign-In
  ├── Google Drive API
  ├── Maps / device location
  ├── Camera / gallery / file picker
  └── Local notifications
```

### 9.1 Backup design constraints

- Google sign-in and Google Drive authorization are distinct steps.
- Drive access must be least-privilege and consent-based.
- Backups contain both structured records and referenced binary attachments.
- Encrypt data before upload; define secure key recovery so encrypted backups remain restorable after device replacement.
- Validate completeness and integrity before restore.
- Show truthful status: local save, backup pending, backup succeeded, backup failed, and offline are different states.
- Automatic background backup is subject to operating-system execution limits.
- Multi-device merge/conflict resolution remains P2, not implied by P0 backup/restore.

### 9.2 Technology decisions versus requirements

| Area | Product requirement | Proposed implementation |
|---|---|---|
| Mobile client | Mobile app, Android first, iOS later | Flutter / Dart |
| Local data | Offline storage and reliable relationships | SQLite with an appropriate Flutter data layer |
| Files | Offline attachment capture/viewing and secure storage | App-private encrypted files with metadata references |
| Identity | Optional Google sign-in | Google authentication integration |
| Cloud | Encrypted user-controlled Drive backup and restore | Google Drive API, app-specific backup storage |
| Location | Save GPS/manual map pin and open location | Device location + Google Maps integration |
| Security | Local/backup encryption, secure token handling | Platform secure storage and reviewed encryption scheme |

No particular package, encryption algorithm, or folder structure is locked by this PRD.

## 10. Release roadmap

### Phase 1 — MVP

Local database; doctor and hospital management; medical visits; medicines; tests; attachments; basic search; editing; and medical history timeline. P0 security controls must be considered throughout rather than postponed until after sensitive data is collected.

### Phase 2 — Secure backup

Google account connection, encrypted Drive backup, manual restore, automatic backup (P1), backup status, and recovery testing. P0 Drive and security requirements are essential for the **complete MVP baseline**, even if delivered as a separate integration milestone after the local-record workflow.

### Phase 3 — Enhanced usability

Advanced filters, map pins, follow-up reminders, medicine history, report previews, PDF export, app lock, and biometrics.

### Phase 4 — Advanced features

Multi-device synchronization/conflict resolution, OCR with user verification, improved search/document organization, and historical summaries.

**Roadmap caveat:** Roadmap phases are delivery groupings, not a replacement for requirement priorities. For example, GPS/map features are P1 even when grouped in Phase 3; encrypted backup remains P0 even if delivered in Phase 2.

## 11. Implementation Priorities for the Current Sprint

This section prioritizes **existing** requirements for a university demonstration while retaining the full product scope. It is a planning recommendation, **not** an assertion about code already written. University review dates and exact evaluation criteria have not been specified.

### 11.1 Core functionality needed for the university review

**Primary demonstration goal:** Show a credible, end-to-end offline-first patient history workflow.

| Sprint focus | Relevant requirement IDs | Demonstrable outcome |
|---|---|---|
| App shell and dashboard | FR-003, FR-010–012, FR-015–016, FR-019 | Launch, view basic counts and recent visits, navigate to add visit |
| Doctors | FR-020–021, FR-023, FR-025, FR-028–031 | Create/search doctor, reopen profile, view history |
| Hospitals | FR-034–037, FR-045, FR-049 | Create/select hospital with address |
| Visits | FR-046–053, FR-058–062 | Create, view, edit, delete, and preserve multiple visits per doctor |
| Medicines | FR-065–069, FR-072–073 | Add/edit multiple medicines for a visit |
| Tests | FR-077–079, FR-081–088 | Add tests and attach/view a report |
| Documents | FR-089–093, FR-095–096 | Capture/import and preview prescription/report offline |
| History and search | FR-100–104, FR-108–109, FR-111–113 | Timeline, doctor/hospital/diagnosis search, basic filtering |
| Essential data protection | FR-130, FR-132–135 | Sensitive local data protected; consent and delete controls are demonstrable |

**University-review demo script:** Create doctor → create hospital → add first visit with medicine/test/prescription → save → reopen doctor → add second visit → verify first remains → search/filter → edit an old visit → reopen attachments offline.

**Critical qualification:** The table is a **review-focused subset**, not a reclassification of P0 requirements. Google sign-in and encrypted Drive backup/restore are also P0 (FR-004–006, FR-009, FR-114–122, FR-131, FR-141) and must be tracked as outstanding until implemented and verified. If the university review explicitly requires cloud integration, move that P0 backup path into the current sprint rather than claiming the local-only demo meets the complete MVP.

### 11.2 Important functionality for the first complete release

Complete **all remaining P0 requirements**, particularly Google authentication/authorization, encrypted Drive backup and restore, local/backup encryption, and recovery validation. Then deliver P1 items, including onboarding, doctor/hospital photos, maps, follow-up scheduling, draft visits, advanced search, richer attachment handling, backup progress/retry/versioning, PIN/biometrics, notifications, export, and sharing. Refer to the full FR tables for the authoritative priorities; this paragraph does not supersede them.

### 11.3 Future enhancements

Deliver the P2 set after the complete release baseline: **FR-033** duplicate-doctor detection; **FR-064** important edit history; **FR-076** medication reminders; **FR-099** prescription OCR; **FR-127** multi-device conflict handling; **FR-149** doctor-wise history summaries. Do not represent these as current sprint obligations unless the project owner explicitly reprioritizes them.

### 11.4 Source-code audit gate

Before beginning implementation in Codex:

1. Inspect repository structure, existing routes/screens, models, persistence, services, and tests.
2. Map each FR ID to **Not Started**, **Partial**, **Implemented (unverified)**, **Verified**, or **Blocked** based on actual evidence.
3. Identify architectural constraints, security gaps, and missing test coverage.
4. Select the smallest viable work items from the current sprint list.
5. Do not mark any FR complete solely because it appears in this document or a design mockup.

## 12. Product acceptance scenarios (12 preserved)

These are end-to-end acceptance scenarios; passing requires observed behavior and appropriate evidence, not a screenshot of a planned design.

1. **Create doctor:** Create a doctor and save their phone, hospital, and photo.
2. **Record visit:** Record a visit with symptoms, diagnosis, and medicines.
3. **Preserve repeat visits:** Add three separate visits under the same doctor without overwriting any.
4. **Upload documents:** Upload a prescription image and laboratory report PDF.
5. **Edit history:** Edit an old visit and retrieve the updated record.
6. **Medicine search:** Search a medicine and find visits where it was prescribed.
7. **Maps:** Open a saved hospital location in Google Maps.
8. **Offline:** Create and view medical records without internet.
9. **Secure backup:** Back up records and attachments to Google Drive securely.
10. **Restore:** Restore the complete history on a new device.
11. **Interrupted backup:** Confirm that an interrupted backup does not corrupt the local database.
12. **Safe disconnection/deletion:** Delete or disconnect backup data without unexpectedly deleting local records.

### 12.1 Acceptance evidence expectations

For each scenario, record test steps, expected and actual results, environment, relevant FR IDs, and pass/fail outcome. Backup/restore scenarios should include attachments and encrypted-key recovery. Offline testing should explicitly disable connectivity. Repeated-visit testing should verify unique visit IDs and preserved earlier content.

## 13. Conflicts, ambiguities, and decisions to resolve

The following are explicitly documented rather than silently changing scope.

| Topic | Established statements | Interpretation / decision needed |
|---|---|---|
| Mandatory Google sign-in vs offline use | Earlier concepts proposed Google login at first launch; latest FR-003 and FR-006 permit offline use and skipping Drive | **Latest requirements govern:** Google sign-in/Drive are optional at onboarding; backup requires later authorization |
| 'Sync' vs backup | Early discussion used automatic Google Drive sync and folder-per-doctor examples; later PRD separates encrypted backup/restore from multi-device conflict handling | **Latest requirements govern:** P0 backup/restore, P1 automatic backup, P2 multi-device conflicts; do not promise live multi-device sync in the MVP |
| Drive folder structure | Earlier illustrative folders and JSON files vs later encrypted, versioned backups | Folder tree was illustrative, **not** an implementation contract; encrypted and restorable backup is the requirement |
| Dashboard medicines vs bottom navigation | Earlier bottom navigation included Medicines; later UI inventory proposes Home/Doctors/History/Reports/Settings | Medicines screen is required, but its navigation placement is a UX decision; five-tab proposal is not a hard functional requirement |
| Initial app-lock priority | Early recommendation mentioned PIN/biometric; latest FR-136–138 classifies these P1 | P1 is authoritative; P0 encryption and secure token handling remain mandatory |
| Roadmap phase vs P0 priority | Phase 1 is local MVP; P0 Drive features appear in Phase 2 | Phases describe incremental delivery; **P0 features remain required for the complete MVP baseline** |
| Reports and attachments ownership | Core model associates attachments with visits/tests, while FR-097 includes doctors | Data design must support doctor-linked attachments without forcing them into a visit |
| Delete doctor vs historical retention | FR-022 allows delete/archive; business rule forbids silent loss of visit history | Define archive/reassignment/explicit deletion behavior in technical design; never cascade-delete silently |
| Doctor/hospital details changing over time | Profiles are editable but visits are historical | Preserve historical facts; choose snapshots or another explicit approach in technical design |
| Encryption and recovery | Backups must be encrypted (FR-117, FR-131) and restorable on a new device (FR-121, FR-141) | Technical design must define key custody and recovery; encryption without recovery does not satisfy restore requirements |
| University review scope | Current sprint focuses on an offline demo, while full P0 includes Drive integration | Demo subset is not the completed product; review criteria may require bringing cloud P0 work forward |

## 14. Delivery and engineering guidance for Codex

- Treat this PRD as the **requirements baseline**, not as a record of implemented features.
- Keep FR IDs in issue/task descriptions, tests, and implementation notes for traceability.
- Audit the actual repository before modifying architecture or reporting completion.
- Prefer vertical slices that produce working end-to-end user journeys, especially doctor → visit → medicines/tests → attachments → history.
- Ensure the data model supports repeated visits and safe editing before building complex UI flows.
- Keep product behavior independent of particular Flutter packages wherever possible.
- Build automated tests for persistence, relationship integrity, search, file association, encryption, backup, and restore.
- Obtain explicit permissions for device features and Google Drive; do not treat login as Drive authorization.
- Distinguish **designed**, **coded**, **tested**, and **released** states in project tracking.

## 15. Final scope statement

The enduring product flow is:

**User → Doctor → Medical Visits → Diagnoses / Symptoms → Medicines / Tests → Prescriptions / Reports → Searchable History → Secure Google Drive Backup / Restore.**

The current university-review sprint can demonstrate the offline core, but the complete requirements remain FR-001 through FR-149 with their original priorities. No implementation status is asserted in this document.
