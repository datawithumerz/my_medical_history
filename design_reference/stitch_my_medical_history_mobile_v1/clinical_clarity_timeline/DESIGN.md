---
name: Clinical Clarity Timeline
colors:
  surface: '#f8f9ff'
  surface-dim: '#d8dadf'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f5fd'
  surface-container: '#eceef3'
  surface-container-high: '#e5eeff'
  surface-container-highest: '#e1e2e8'
  on-surface: '#191c20'
  on-surface-variant: '#424753'
  inverse-surface: '#2e3135'
  inverse-on-surface: '#eff0f6'
  outline: '#737784'
  outline-variant: '#c2c6d5'
  surface-tint: '#0f5ac3'
  primary: '#004297'
  on-primary: '#ffffff'
  primary-container: '#0d59c2'
  on-primary-container: '#c9d7ff'
  inverse-primary: '#afc6ff'
  secondary: '#5b5e66'
  on-secondary: '#ffffff'
  secondary-container: '#dfe2eb'
  on-secondary-container: '#61646c'
  tertiary: '#00512a'
  on-tertiary: '#ffffff'
  tertiary-container: '#006c39'
  on-tertiary-container: '#90eaaa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#afc6ff'
  on-primary-fixed: '#001a43'
  on-primary-fixed-variant: '#004398'
  secondary-fixed: '#dfe2eb'
  secondary-fixed-dim: '#c3c6cf'
  on-secondary-fixed: '#181c22'
  on-secondary-fixed-variant: '#43474e'
  tertiary-fixed: '#9bf6b5'
  tertiary-fixed-dim: '#80d99b'
  on-tertiary-fixed: '#00210e'
  on-tertiary-fixed-variant: '#00522a'
  background: '#f8f9ff'
  on-background: '#191c20'
  surface-variant: '#e1e2e8'
  primary-variant: '#0b4ca8'
  surface-card: '#ffffff'
  text-primary: '#191c20'
  text-secondary: '#43474e'
  text-tertiary: '#737784'
  outline-hairline: '#dce2ee'
  timeline-track: '#c2c6d5'
  warning-amber: '#855300'
  warning-amber-container: '#fef3c7'
  warning-amber-text: '#78350f'
  success-green: '#006d3a'
  success-green-container: '#dcfce7'
  success-green-text: '#004020'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Inter
    fontSize: 19px
    fontWeight: '600'
    lineHeight: 26px
  title-md:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system is engineered specifically for adult, caregiver, and senior demographics managing personal longitudinal health records on Android. It anchors on a Modern Health Timeline direction that emphasizes calm reliability, cognitive legibility, and architectural transparency.

### Core Philosophy
- **Calm & Unhurried**: Hospital visits, medication regimens, and health tracking can be stressful. The UI reduces cognitive overhead through quiet, high-contrast typography, ample whitespace, and deliberate color restraint.
- **Clinical Dignity**: No artificial gamification, pseudo-wellness rings, or misleading decorative trust seals. Visual weight is earned strictly through verified health data, clear dates, and structural hierarchy.
- **Physical Document Metaphor**: Interface containers behave like crisp, high-grade clinical record folios, physical lab reports, and chronological medical charts.
- **Architectural Honesty (Storage & Sync)**: The system treats user health data with total transparency across three distinct tiers:
  1. **Local on-device storage**: 100% offline-ready, instantaneous read/write, resilient SQLite/Room-backed store.
  2. **Account sync**: Cloud synchronization backed by Supabase, labeled strictly as "Account sync" across user-facing settings.
  3. **Google Drive backup & restore**: Explicit, user-initiated or automated file snapshots, fully segregated from real-time account sync to avoid user confusion.
- **Non-Destructive Conflict Model**: Conflicting modifications never overwrite data silently. Divergent records are presented in side-by-side comparison sheets and preserved as linear revision histories on the same record entity.

## Colors

The color palette prioritizes clinical authority and accessible contrast ratios (exceeding WCAG 2.1 AAA for body copy, AA for graphic controls).

- **Primary Deep Medical Blue (`#0D59C2` / `#0B4CA8`)**: Drives primary interactions, major date markers, FABs, and selected states. Never used for purely ornamental fills.
- **Surfaces & Backgrounds**:
  - `surface` (`#F8F9FF`): The soothing ambient background, preventing screen glare under artificial medical lighting.
  - `surface-card` (`#FFFFFF`): Elevated pure-white cards for individual timeline entries, lab results, and medication records.
  - `surface-container-low` (`#F1F5FD`): Recessed containers, grouped attribute tables, search bars, and metadata tiles.
- **Neutral Dark & Typographic Contrast**:
  - `text-primary` (`#191C20`): High-density near-black for headings, medications, dosages, and vital figures.
  - `text-secondary` (`#43474E`): Muted charcoal for secondary descriptors, doctor specialties, and time stamps.
  - `text-tertiary` (`#737784`): Dedicated to minor auxiliary units, disabled states, and timeline connector guides.
- **Semantic Feedback & Synchronization Accents**:
  - **Success / Validated Sync**: Deep forest green (`#006D3A`) on light mint tint (`#DCFCE7`), text `#004020`. Used for verified lab reports, active prescriptions, and "Synced just now" status.
  - **Conflict / Attention Required**: Warm clinical amber (`#855300`) on amber tint (`#FEF3C7`), text `#78350F`. Applied to version discrepancies, allergy warnings, and unmerged modifications.
  - **Error / Critical Alert**: Deep medical red (`#BA1A1A`) on pale rose (`#FFDAD6`). Strictly reserved for failed operations, critical lab flags, or irrevocable deletions.

## Typography

Typography is built on **Inter**, an accessible grotesque with superior legibility at small sizes, optimized for Android's system font rendering.

- **Baseline Body Size (16sp)**: The primary reading scale is calibrated at `16sp` (`body-md`, `24px` line-height) to safeguard readability for patients experiencing fatigue, low vision, or cognitive strain.
- **Tabular Figures for Clinical Numerals**: Inter's tabular numbers (`tnum`) must be enabled on all date columns, biometric vitals (blood pressure, glucose levels), and dosage values (e.g., `250 mg`, `10 ml`) to facilitate fast vertical alignment and prevent reading errors.
- **Accessibility & Dynamic Type**: No critical text node drops below 11sp. All layouts support Android's system font scale up to 200% without truncating clinical dosage titles or clipping confirmation actions.

## Layout & Spacing

The layout is anchored to a strict **4dp/8dp incremental grid**:

- **Touch Envelope (Strict Minimum 48dp)**: Every interactive control—including icons, filter chips, radio targets, and timeline nodes—resides within a minimum boundary of 48×48dp to ensure effortless usability during motor tremor or low-dexterity scenarios.
- **Canvas Margins & Gutters**:
  - Portrait mobile uses a 16dp (`1rem`) outer screen margin.
  - Content containers on tablets or foldables enforce a maximum width of `680dp` with 24dp (`1.5rem`) margins.
- **Timeline Vertical Rhythm**:
  - Timeline cards are vertically separated by `12dp` to `16dp`.
  - Nested diagnostic data, dosages, or physician notes inside a card follow an `8dp` rhythmic cadence.
  - Spacing between timeline date groups spans `24dp` (`1.5rem`).

## Elevation & Depth

Visual hierarchy uses crisp boundary containment combined with subtle, slate-tinted ambient depth instead of heavy drop shadows:

- **Surface 0 (Canvas)**: `#F8F9FF` background with zero elevation.
- **Surface 1 (Timeline & Medical Cards)**: Pure white `#FFFFFF` surface enclosed by a 1px solid `#DCE2EE` border, coupled with a gentle ambient shadow: `box-shadow: 0 1px 3px 0 rgba(25, 28, 32, 0.05), 0 1px 2px -1px rgba(25, 28, 32, 0.03)`.
- **Surface 2 (Floating Action & Header App Bar)**: Scrolled state top app bar and Floating Action Button (FAB): `box-shadow: 0 4px 6px -1px rgba(25, 28, 32, 0.08), 0 2px 4px -2px rgba(25, 28, 32, 0.04)`.
- **Surface 3 (Modal Bottom Sheets & Conflict Comparison)**: Heavy task surfaces, resolution panels, and prescription viewers: `box-shadow: 0 12px 24px -4px rgba(25, 28, 32, 0.16)`.
- **Bottom Navigation Surface**: Solid `#FFFFFF` sitting above a 1px hairline border (`#DCE2EE`) with 3dp upward elevation to establish an unambiguous boundary above continuous timeline scrolling.

## Shapes

The design uses balanced, approachable contours that maintain efficient use of screen space:

- **Medical Record & Timeline Cards**: Radii set between **16dp and 20dp** (`rounded-lg` / `rounded-xl`). This delivers a friendly, contemporary container without obscuring multi-column clinical data.
- **Modal Bottom Sheets**: Top corners are rounded to `24dp` with flat bottom corners hugging the Android display boundary.
- **Interactive Controls (Buttons, Text Inputs)**: Rounded to `12dp` for tactile clarity.
- **Pills & Status Indicators**: Fully rounded pill shapes (`9999px`), styled as honest functional tags with clear typography, strictly avoiding artificial "military-grade encryption" badges or deceptive marketing stamps.

## Components

### 1. Timeline & Record Cards
- **Structure**: Corner radius of 16dp–20dp, surface `#FFFFFF`, border 1px `#DCE2EE`, internal padding 16dp.
- **Timeline Connector**:
  - A persistent vertical 2dp guide line (`#C2C6D5`) links events chronologically.
  - Timeline node is a 14dp circle anchored to the timeline track. Node fill aligns with event category: Clinical Appointment (`#0D59C2`), Lab Result (`#006D3A`), Medication Update (`#43474E`), or Action/Alert (`#855300`).
- **Header**: Primary condition, procedure, or lab name in `title-md` (`#191C20`) with semantic status badge aligned top-right.
- **Content Blocks**: Key-value data (e.g., Ordering Doctor, Facility, Reference Range) styled in `body-sm` (`#43474E`) with values emphasized in `label-lg` (`#191C20`).

### 2. Status & Diagnostic Pills
- **Active Treatment / Normal Range**: Background `#DCFCE7`, text `#004020`, 12sp semibold.
- **Pending / Action Required**: Background `#FEF3C7`, text `#78350F`, 12sp semibold.
- **Past / Archived**: Background `#F1F5FD`, text `#43474E`, 12sp semibold.
- **Formatting Principle**: Clean, understated text and background pairings. Avoid decorative shield icons or unverified trust seals.

### 3. Storage, Sync & Backup Controls
- **Account Sync Indicator**:
  - Displayed in App Bar or Settings as "Account sync".
  - States: `Synced` (subtle checkmark, `#006D3A`), `Syncing...` (rotating loader, `#0D59C2`), or `Offline — Saved locally` (`#43474E`).
- **Google Drive Backup & Restore**:
  - Independent settings section clearly separated from real-time Account sync.
  - Provides explicit actions: "Back up now to Google Drive" and "Restore from snapshot" with timestamp of last drive archive.

### 4. Conflict Resolution Model (Side-by-Side Sheet)
- **Modal Comparison**: Triggered when local offline modifications differ from cloud updates.
- **Layout**: Two-column side-by-side card comparison inside a 24dp rounded bottom sheet:
  - **Left Column**: "Local Edit (This Device)" with edit timestamp.
  - **Right Column**: "Account Sync Version (Cloud)" with source timestamp.
  - Highlighting: Conflicting fields are highlighted in `#FEF3C7` with `#78350F` borders.
- **Resolution Actions**:
  - "Keep Both (Create Revision)": Merges both entries non-destructively, preserving divergent edits as navigable revision histories on the same record without duplicating the timeline event.
  - "Choose Local" or "Choose Cloud": Confirms the authoritative version while logging the discarded state to the record's audit log.

### 5. Buttons & Interactive Targets
- **Primary CTA**: `#0D59C2` fill, `#FFFFFF` label (`label-lg`), height 52dp (exceeds 48dp minimum for reliable tap acquisition), 12dp radius. Pressed state: `#0B4CA8`.
- **Secondary Action**: `#F1F5FD` fill, `#191C20` label, 1px border `#DCE2EE`.
- **Destructive Action**: Transparent fill with `#BA1A1A` border and label; filled `#BA1A1A` reserved strictly for confirming permanent file deletion.

### 6. Input Fields
- **Container**: Height 56dp, 12dp corner radius, background `#FFFFFF`.
- **Border States**: Static 1.5px `#DCE2EE`; focus state 2px `#0D59C2` with an ambient focus ring.
- **Labels & Help**: Floating label in `label-md`; persistent helper or validation error in 13sp immediately below input.

### 7. Bottom Navigation Bar
- **Architecture**: 5 tabs (Home / Timeline, Records, Doctors, Medications, Settings).
- **Height**: 68dp + system navigation bar insets.
- **Active State**: Primary deep blue icon (`#0D59C2`), `label-sm` semibold text (`#0D59C2`).
- **Inactive State**: Outlined icon (`#43474E`), regular `label-sm` text (`#737784`).
- **Touch Target**: Each tab provides a centered 64×48dp minimum touch target.