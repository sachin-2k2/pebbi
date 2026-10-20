# AGENTS.md — Pebbi Flutter App

Read this file fully before writing any code. Follow it for every task. If something here conflicts with a request, ask before proceeding.

---

## 1. Scope

**Pebbi** is a mobile language-learning app ("Speak it for real"): short lessons, real-life AI role-play missions, spaced-repetition review, and gentle gamification (stars, streaks, badges, stickers, mascot outfits).

- **Your job: the Flutter app only.**
- **Target devices: Android phones, Android tablets, iPhones, and iPads** (portrait and landscape, including split-screen/multitasking windows and foldables). Every screen must be **responsive**. No fixed-size layouts. See Section 4.
- **The backend is built by a separate backend team.** Do NOT design, suggest, or write server code, database schemas, API endpoints, or server logic. Do not prescribe what the server should do.
- The app talks to the backend through **repository interfaces**. Until the real API is provided, use **mock/fake repositories** with realistic sample data. When the backend team provides API docs, only the repository implementations and DTOs change; screens and providers stay the same.
- Never hardcode server URLs, keys, or secrets. Use environment/config files.
- **Reference design:** a web prototype built in Base44 (React). It is a **UI and flow reference only**. Do NOT port its code or its local-storage persistence. Recreate the screens natively in Flutter.

---

## 2. Architecture

### 2.1 Folder structure (feature-first)

```
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp, theme wiring
│   ├── router.dart              # go_router + auth/onboarding redirects
│   └── shell/                   # bottom tab bar + app frame
├── core/
│   ├── design_system/           # Button3D, BottomSheet, Ring, chips, Pebbi mascot, tokens
│   ├── theme/                   # colours, typography, dark mode, accent, text scale, spacing tokens
│   ├── layout/                  # breakpoints, ResponsiveBuilder, AdaptiveShell, TwoPane, ContentWidthLimiter, ResponsiveGrid
│   ├── network/                 # dio client, interceptors, error mapping
│   ├── storage/                 # local DB, preferences, secure storage
│   ├── services/                # speech, tts, audio, haptics, notifications, ads, purchases
│   └── utils/
├── features/
│   ├── onboarding/
│   ├── auth/
│   ├── path/
│   ├── lesson/
│   ├── missions/
│   ├── review/
│   ├── rewards/
│   ├── premium/
│   ├── settings/
│   └── emergency/
└── l10n/
```

Each feature uses the same layers:

```
features/<name>/
├── data/            # DTOs, repository implementations (mock now, real later)
├── domain/          # models, repository interfaces, pure rules (NO Flutter imports)
└── presentation/
    ├── providers/   # Riverpod notifiers
    ├── screens/     # thin screen files (composition only)
    └── widgets/     # all UI pieces, one widget per file
```

### 2.2 Layer rules

1. Screens only **read providers and call notifier methods**. Screens never call APIs, databases, or services directly.
2. Providers talk to **repositories**. Repositories hide where data comes from (mock, local cache, or API).
3. `domain/` code has **no Flutter imports** so it can be unit tested.
4. Shared UI lives in `core/design_system`. Do not duplicate buttons, sheets, or rings inside features.
5. Features do not import each other's screens. They share models and providers, and navigate through the router.
6. No business logic in widgets. No magic numbers; put constants in named config files.

### 2.3 State management: Riverpod

- Use `flutter_riverpod` with `riverpod_annotation` (code generation).
- Remote/async data: `AsyncNotifier` / `FutureProvider` with loading, error, and cached states.
- Session state (current lesson, current mission chat): `autoDispose` notifiers that reset when the user leaves.
- Derived values (streak, level, due count, premium status): plain `Provider`s watching other providers. Do not store derived values.
- Settings (theme, accent, text size, reduce motion, left-handed): a persisted notifier watched at the app root.
- Use `select` to limit rebuilds.
- Models: `freezed` + `json_serializable`. Routing: `go_router`. Networking: `dio`.

### 2.4 Packages

`flutter_riverpod`, `riverpod_annotation`, `go_router`, `freezed`, `json_serializable`, `dio`, `drift` (local DB), `shared_preferences`, `flutter_secure_storage`, `connectivity_plus`, `speech_to_text`, `flutter_tts`, `just_audio`, `rive` or `lottie`, `flutter_local_notifications`, `google_mobile_ads`, `purchases_flutter`, `wakelock_plus`. Ask before adding any package not on this list.

---

## 3. Widget and file-size rules (IMPORTANT)

**Never build a whole screen in one file.** Screen files must stay small and readable. Break every UI into widgets.

### 3.1 Hard limits

- A **screen file** contains only the `Scaffold`/layout and a list of child widgets. Target **under ~100 lines**, never more than ~150.
- A **`build()` method** should stay under ~50 lines. If longer, extract widgets.
- **One public widget per file.** File name matches the widget (`path_node.dart` → `PathNode`).
- Any widget over ~150 lines must be split further.
- No widget-returning helper methods like `_buildHeader()`. Extract a real widget class instead (so it can be `const`, tested, and rebuilt independently).

### 3.2 Where widgets go

| Widget type | Location |
|---|---|
| Used by one screen only | `features/<name>/presentation/widgets/` (can group in sub-folders per screen) |
| Used by several features | `core/design_system/` |
| Small private helper used by one widget only | Private class (`_Name`) in the same file, only if under ~30 lines |

### 3.3 Widget design rules

- Use `const` constructors wherever possible.
- Widgets take **plain data + callbacks** as parameters. Only "container" widgets at the top of a screen read Riverpod providers; leaf widgets stay dumb and reusable.
- Use `ConsumerWidget` only where a provider is actually read; otherwise `StatelessWidget`.
- Keep animation controllers and local UI state inside the small widget that needs them, not in the screen.
- Spacing, colours, radius, and text styles come from theme tokens, never inline literals.
- No hardcoded widths or heights for layout. Size comes from constraints, flex, and tokens (see Section 4).
- Lists use `ListView.builder` / slivers, not giant `Column`s.

### 3.4 Expected breakdown (examples)

**Path screen** → `TopPills`, `TrackChips`, `ContinueCard`, `DueStrip`, `AdBanner`, `PathRail`, `PathNode`, `UnitHeader`, plus sheets `ProfileSheet`, `StreakSheet`, `StarsSheet`, `LockedNodeSheet`.

**Lesson screen** → `LessonIntro`, `LessonProgressBar`, `ExerciseHost` (switches on exercise type), `NewPhraseCard`, `ChoiceExercise`, `PictureMatchExercise`, `BuildSentenceExercise`, `MatchPairsExercise`, `FillBlankExercise`, `ReplyExercise`, `SayItOutLoudExercise`, `HintButton`, `FeedbackPanel`, `RedoRoundBanner`, `LessonComplete`. All exercises share one common interface (`onAnswered(result)`), so the host stays tiny.

**Missions** → `TodayMissionCard`, `SceneCard`, `CategoryFilter`, `MissionBrief`, `ChatBubble`, `MicButton`, `CaptionToggle`, `DebriefScores`, `CorrectionTile`.

**Rewards** → `GoalRing`, `StreakCalendar`, `QuestRow`, `BadgeCard`, `BadgeGrid`, `StickerBook`, `LevelProgress`, `InviteCard`.

**Review** → `ReviewTabs`, `PhraseTile`, `PhraseFilterBar`, `PracticeCard`, `Flashcard`, `LibraryEntry`, `AddPhraseSheet`.

**Onboarding** → one widget per setup step (`AgeBandStep`, `NativeLanguageStep`, `TargetLanguageStep`, `ReasonStep`, `PlacementIntroStep`, `GoalStep`, `ReminderStep`, `MeetPebbiStep`, `OfferStep`, `CourseReadyStep`), plus shared `StepScaffold` and `OptionCard`.

**Settings** → `SettingsSection`, `SettingsTile`, `SwitchTile`, `SliderTile`, `ChoiceTile`.

### 3.5 Self-check before finishing any task

- Is any screen file over ~150 lines? Split it.
- Is any `build()` over ~50 lines? Extract widgets.
- Are there widget-returning helper methods? Convert to classes.
- Is the same UI copied in two places? Move it to a shared widget.
- Does any widget use a fixed width/height, `Platform.isIOS`/tablet checks, or an unbounded row/column that can overflow? Fix it (Section 4).

---

## 4. Responsive and adaptive layout (IMPORTANT)

The app must look and work correctly on **Android phones, Android tablets, iPhones, and iPads**, in portrait and landscape, in split-screen or resized windows, and on foldables. **Do not design for one screen size.**

### 4.1 Absolute rules

1. **No fixed layout sizes.** Never hardcode widths/heights for screens, cards, containers, or images (for example `width: 375`, `height: 812`). Use constraints, flex, and fractions instead.
2. **Decide layout from the window size, not the device.** Use `LayoutBuilder` / `MediaQuery.sizeOf(context)` (prefer `sizeOf`; avoid `MediaQuery.of(context).size`, which rebuilds too often). **Never** use `Platform.isIOS`, device names, or "is tablet" checks to choose a layout. An iPad in Split View or an Android phone in a small window must get the compact layout.
3. **Do not scale everything linearly from one design width** (no "375px artboard × screen width" scaling). It makes tablets look giant. Use breakpoints, max content widths, and spacing tokens.
4. **Content must never overflow.** No yellow/black overflow stripes at any size or text scale. Text wraps or ellipsizes; content scrolls when needed.
5. Support **text scale up to 200%** and the in-app text-size setting without clipping.
6. Respect **safe areas** (notches, Dynamic Island, home indicator, Android gesture/edge-to-edge bars, foldable hinges via display features).

### 4.2 Breakpoints (window width, defined once in `core/layout`)

| Class | Width | Typical devices |
|---|---|---|
| Compact | under 600 | Phones (portrait), small split-screen windows |
| Medium | 600 to 839 | Large phones landscape, small tablets, foldables, iPad portrait in multitasking |
| Expanded | 840 and up | Tablets, iPads, landscape tablets, large windows |

Expose them as named constants and one helper (for example `context.windowClass`). No other file defines its own breakpoint numbers.

### 4.3 Layout behaviour by size

| Area | Compact | Medium | Expanded |
|---|---|---|---|
| Navigation | Bottom tab bar | Navigation rail | Navigation rail (extended labels) or side panel |
| Path (home) | Full-width single column | Centered column | Centered rail with max width, optional side panel (profile/stats/Continue card) |
| Lesson / exercises | Single column, full width | Centered column with max width | Centered column with max width (roughly 560 to 720), never stretched edge to edge |
| Onboarding / auth | Single column | Centered card with max width | Centered card, or image/mascot on one side and form on the other |
| Missions | List then brief then chat as separate pages | List with larger cards in a grid | Two panes: scene list + brief/preview |
| Review | Tabs, list | Tabs, list/grid | Two panes: phrase list + detail |
| Rewards | 2-column badge grid | 3 to 4 columns | 4 to 6 columns, side-by-side sections |
| Settings | One list, drill-down | One list | Two panes: sections list + section detail |
| Sheets/dialogs | Bottom sheet | Bottom sheet with max width | Centered dialog or side sheet with max width |

If a tablet design is not provided, **follow this table** and list the assumption in your summary.

### 4.4 Tools to use

- `LayoutBuilder`, `Flexible`/`Expanded`, `FractionallySizedBox`, `AspectRatio`, `Wrap`, `ConstrainedBox(maxWidth)`, `Align`/`Center`.
- Grids: `SliverGridDelegateWithMaxCrossAxisExtent` (columns adapt automatically), not a fixed column count.
- Lists/grids with many items: slivers or `.builder`.
- Images: `BoxFit` + `AspectRatio`; use scalable assets (SVG, Rive, Lottie) for the mascot and icons so they stay sharp.
- Ads: use **adaptive banner** sizes.
- Platform feel: prefer `.adaptive` widgets (switches, dialogs, progress) and platform scroll/back behaviour. This is about look and feel only, not layout.

### 4.5 Reusable layout widgets (build in `core/layout`, before feature screens)

- `ResponsiveBuilder`: builds `compact` / `medium` / `expanded` variants from window width.
- `AdaptiveShell`: bottom tabs on compact, navigation rail on medium/expanded.
- `ContentWidthLimiter`: centers content and caps its max width.
- `TwoPaneLayout`: list + detail on expanded, single pane with navigation on compact.
- `ResponsiveGrid`: grid with max-extent columns and spacing from tokens.
- `AdaptiveSheet`: bottom sheet on compact, dialog/side sheet on larger windows.

Screens compose these. They do not repeat size logic.

### 4.6 Design-system components must be flexible

`Button3D`, `Ring`, chips, cards, `PathNode`, and the mascot take size from **constraints and theme tokens** (min height, padding, scale factor clamped between a minimum and maximum), not fixed pixels. Minimum tap target 48dp. Spacing and radius come from tokens, which may step up slightly on larger window classes.

### 4.7 Orientation and windows

- **Tablets (medium/expanded): support portrait and landscape. Do not lock orientation.**
- Phones: portrait is the primary layout. Landscape must still work without overflow (see open questions about locking).
- Handle runtime window changes (iPad Split View/Slide Over, Android multi-window and freeform, foldable open/close) without losing screen state or restarting a lesson or mission.

### 4.8 Required responsive tests

Add widget/golden tests for every screen at these sizes (logical pixels), at text scale 1.0 and 2.0, in light and dark mode:

| Size | Represents |
|---|---|
| 360 x 640 | Small Android phone |
| 390 x 844 | iPhone |
| 430 x 932 | Large phone |
| 800 x 1280 | Android tablet, portrait |
| 1280 x 800 | Android tablet, landscape |
| 1024 x 1366 | iPad Pro, portrait |
| 700 x 900 | Split-screen / foldable window |

A test fails on any overflow error. Also run each main flow once on a phone emulator, a tablet emulator, and an iPad simulator.

---

## 5. Offline-first behaviour (client side)

**Principle:** The UI reads from the local database and never blocks on the network.

```
UI → Provider → Repository → Local DB (reads)
                    └── Sync (repository) ⇄ API (provided by backend team)
```

### 5.1 What must work offline

| Feature | Offline |
|---|---|
| Emergency phrasebook (8 phrases) | Always. Bundled or downloaded on first run, with audio |
| Downloaded lessons / offline packs | Yes |
| Review and flashcards | Yes (local review queue) |
| Saving lesson progress | Yes (queued locally, sent when online) |
| Speaking exercises | Only with on-device speech recognition; otherwise use the self-check fallback |
| AI missions, sign-in, purchases, "add a phrase" translation | No. Show a clear "needs internet" state with retry |

### 5.2 Client behaviour

- Write user actions (lesson completed, phrase answered, mission finished, phrase saved) to the local DB first and add them to a local **outbox** queue.
- Send queued items when online, with retry and backoff. Give each queued item a unique client-generated ID so retries are safe.
- Trigger sync on: app open, after each lesson, and when connectivity returns. Do not rely on background sync.
- Downloaded content packs are stored in app storage; Settings shows pack size, progress, and a delete option. Free users cache the first unit.
- UI: small non-blocking "Offline" banner, "last updated" on cached screens, clear locked-state messages for online-only features.
- Cache the premium entitlement with an expiry and a grace period so premium users are not locked out offline.
- Exact sync/merge rules and field names come from the backend team's API docs. Do not invent them; ask.

---

## 6. User isolation (logout / login safety)

**Rule: a new user must never see a previous user's data.**

- Identity: guest = `guest_<uuid>`; signed in = the user ID from the API.
- **Use one local database file per user ID.** Open only the active user's file. Every table also has a `userId` column as a second guard.
- A single `currentUserProvider` drives everything. All user-data providers watch it, so they rebuild empty when it changes. Repositories get the user ID from it, never from a global variable.

### On logout, always:

1. Try to send the outbox. If offline, keep unsent items in the old user's own database and warn the user ("You have unsynced progress. Log out anyway?").
2. Delete access/refresh tokens from `flutter_secure_storage`.
3. Invalidate all user-data Riverpod providers; clear in-memory caches and the HTTP auth header.
4. Unregister the push token (via the API) and **cancel all scheduled reminder notifications**.
5. Clear user-specific image/audio caches (shared course content may stay).
6. Reset navigation to login/onboarding.

### Guest → account

- Guest data lives in the guest database. When the guest signs up or signs in, hand the guest progress to the repository for migration (rules from the backend team), then move/delete the guest DB.
- If the account already has data, do not wipe either side. Ask the user only for a real conflict (for example two different target languages).

### Security

- Tokens only in secure storage (Keychain/Keystore).
- Consider SQLCipher encryption for the local DB (age-band data for children).
- Never log personal data to analytics or crash reports without consent.

---

## 7. App structure and screens

### 7.1 Navigation

```
Splash → Welcome cards → Setup (11 steps) → Home

Bottom tabs: Path | Missions | Review | Rewards
Home top pills: Language switcher, Streak sheet, Stars sheet, Profile sheet → Settings / Premium / Account
```

(Confirm exact tab list against screenshots when provided. On medium/expanded windows the bottom tabs become a navigation rail, see Section 4.3.)

### 7.2 Pages (15 + 404)

Onboarding, Login, Register, ForgotPassword, ResetPassword, OAuthConsent, Path, Lesson, Missions, MissionSession, Review, Rewards, Premium, Settings, EmergencyPhrasebook, plus a Not Found page. Many "screens" are sheets or states inside these (about 30+ in total).

### 7.3 Screen behaviour

- **Onboarding:** splash, welcome cards, then steps: age band (enables child-safe settings), language you speak, language to learn, reasons (multi-select), optional 2-minute placement, daily goal, reminder time + days, meet Pebbi + accent colour, premium offer, "course ready". One question per step, progress indicator, back button.
- **Auth:** the app works as a guest with no account. Prompt sign-up when the user starts their first lesson and from Settings. Include password reset.
- **Path (home):** top pills (language, streak, stars, profile); track chips (Everyday, Travel, Work & Interview, Life Abroad, Exams, shown only if content exists); Continue card; "phrases due" strip linking to Review; ad banner for free users; units as a winding rail of nodes (lesson, Review, Mission, Chest), each done / current / locked.
- **Locked node:** sheet offering "Go back" or "Test out" (8 quick questions; passing opens the unit).
- **Lesson:** intro (what you'll learn, speaking on/off) → mixed exercises → feedback after each answer with a "why this answer" panel → redo round for mistakes → finish screen (stars, streak, first-try score). Exercise types: new phrase card, listen-and-choose, picture match, build sentence from tiles, match pairs, fill the blank, reply to a line, say it out loud (mic, with self-check fallback). Hints remove a wrong option.
- **Missions:** today's mission, Emergency phrasebook, Free talk, 7 scenes (café, directions, hotel, pharmacy, market, meeting a neighbour, job interview) with category filters and difficulty. Brief screen: goals, chat or voice, guided or light hints, captions, correction style.
- **Mission session:** role-play with a character who speaks only the target language. Debrief shows scores (understood, clear, polite, goals hit), up to 3 corrections with better phrasing (each savable to the phrasebook), and what you said well.
- **Review:** Phrases tab (All / Tricky / New / Saved, one-tap "practise tricky"); Practice tab (2-minute mix, flashcards, tricky phrases); Library tab (saved phrasebook, grammar and culture notes, "add a phrase").
- **Rewards:** daily goal ring, streak with 28-day calendar, quests, badges, sticker book, level + outfit progress, invite card.
- **Emergency phrasebook:** 8 large phrase cards, play-aloud button, screen kept awake, works offline.
- **Premium:** free tier gets the first unit of each language; premium unlocks all units, all languages, unlimited missions, no ads, offline packs, exam tracks. Free users can watch a rewarded ad for a 24-hour unlock. One gentle reminder per day for free users, only after their first lesson.
- **Settings:** language, level, explanation language, helper line; daily goal and reminders; sound, haptics, autoplay, speaking practice; theme, accent colour, text size; reduce motion, captions, left-handed controls; account, plan, reset; privacy, help, about.

---

## 8. Design system (build FIRST, before feature screens)

Build and test the layout helpers in `core/layout` (Section 4.5) and these components in `core/design_system` before any feature. All components must be size-flexible (Section 4.6):

`Button3D` (pressed and disabled states), `BottomSheet`, `Ring` (progress), chips/pills (`Bits`), `Shell` + `TabBar` (with left-handed mode), `Pebbi` mascot (outfits + accent colour), `StickerBurst` animation, `InviteCard`, `Logo`, splash gate.

Known tokens: brand purple `#6C4DF6`, user-selectable accent colours, light and dark themes, text-size scale setting. **Do not guess spacing, radius, or fonts.** Ask for screenshots/tokens and put them in `core/theme` as named constants.

Every screen must handle: phone, tablet, and iPad sizes in portrait and landscape, split-screen windows, guest vs signed-in, free vs premium, loading / empty / error / offline, dark mode, large text, reduce motion, left-handed layout, RTL (Arabic), non-Latin fonts (Japanese, Arabic), and mic-permission-denied.

---

## 9. Reference rules from the prototype

These describe what the prototype does. **If the backend provides the value, display what the API returns; do not re-implement it on the client.** If it is unclear who owns a rule, ask.

- **Review scheduling (prototype):** each phrase has box 0–3 and a due date. Correct answer: box +1 (max 3); wrong: reset to 0. Gaps in days by box: 0, 1, 3, 7. Box 3 = "strong". Track seen / right / wrong / last date per phrase. If the client owns this, implement as a pure Dart class with unit tests.
- **Stars (prototype values):** finish a stop = 10 + 2 per first-try correct answer; pass test-out = 15; open chest = 20; finish mission = 25. The per-stop 1–3 rating is a display score only. Level comes from total stars (8 levels, each unlocks a Pebbi outfit).
- **Streak:** consecutive active days ending today (or yesterday if today has no activity yet).
- **Badges shown in the UI (12):** First hello, 10 stars, Fifty stars, Review hero, Conversation starter, Scene stealer, Voice starter, Three days running, Week of fire, Script explorer, Polyglot heart, Café regular. Each has an emoji, name, "how to earn" text, earned state, and optional progress (current/target). Build `BadgeCard` to handle locked, in-progress, and earned states, and a "new badge" celebration.
- **Quests shown in the UI (4):** Practise one lesson today, Finish a real-life mission, Get 10 phrases to strong, Three days in a row. Each has an emoji, label, progress, and target.
- **Calendar:** rolling last 28 days ending today, each with a day number and an active flag.

### Prototype flaws: do NOT copy in the UI/client logic

1. Do not derive language from the first two letters of an ID; use an explicit language field.
2. Do not match items by ID suffix patterns.
3. Do not persist derived values (streak, level, due count, premium status).
4. Do not store all app state as one JSON blob. Use structured local tables.

---

## 10. Backend integration (owned by the backend team)

- Code against repository interfaces and a DTO → domain model mapping layer, so API changes stay in `data/`.
- Do not define endpoints, request shapes, or server behaviour. If you need data the UI requires, add it to a **`BACKEND_QUESTIONS.md`** file as a plain list ("Rewards screen needs: badge progress current/target, earned date…") for the Flutter developer to send to the backend team.
- Handle API errors centrally in `core/network` (timeouts, 401 → logout flow, no connection → offline state) and show friendly messages.

---

## 11. Child safety and privacy

- Age band is collected at onboarding and must enable child-safe behaviour in the app (restrict ads, safer AI-chat UI, minimal data collection). Check COPPA / GDPR-K rules before shipping.
- Never put AI provider keys in the app.
- No analytics or tracking without a documented consent screen.

---

## 12. How you (the agent) must work

1. **Plan before coding.** For any task bigger than one file, write a short plan (files to create, widgets, providers, models) and wait for confirmation.
2. **Work in small steps.** One feature or one design-system component per task.
3. **Follow the build order:**
   1. Theme + spacing tokens, breakpoints and layout helpers (`core/layout`), design system, router, adaptive shell, local storage
   2. Onboarding + guest profile + auth screens
   3. Path + lesson engine (text exercises first)
   4. Rewards + review
   5. Speech (STT/TTS), then missions
   6. Premium, settings, offline packs, notifications, ads
4. **Do not invent.** If a design detail, API field, rule, or copy is missing, add a `// TODO(question)` placeholder and log it in `BACKEND_QUESTIONS.md` or the open-questions list. Never guess business rules.
5. **Mock first.** Every screen must run with fake repositories before the real API exists.
6. **Keep screens thin.** Apply Section 3 (widgets) and Section 4 (responsive) on every task, including the self-checks.
7. **Tests are required** for: answer checking, review scheduling (if client-owned), reward/badge display logic, outbox retry, and user isolation (Section 13).
8. **Code quality:** `flutter analyze` clean, `dart format`, no unused code, descriptive names, `const` where possible.
9. **Accessibility and responsiveness are part of "done":** semantic labels, large-text support, tap targets of at least 48dp, reduce-motion respected, sufficient contrast.
10. **Never copy secrets, keys, or personal data** into the repo or logs.
11. **After each task, summarise:** what changed, widgets created, what is still mocked, new open questions.

---

## 13. Definition of done and required tests

A feature is done only when:

- It runs with mock data and with the real repository interface.
- Loading, empty, error, and offline states exist.
- It works in light/dark mode, large text, and RTL where relevant.
- It is responsive: no overflow and a sensible layout on phone, tablet, and iPad sizes in portrait and landscape (tests in Section 4.8).
- Screen files and `build()` methods respect the size limits in Section 3.
- Unit tests cover its domain rules; widget tests cover key flows.

Integration tests that must exist before release:

1. User A logs in, does a lesson, logs out, user B logs in: B sees no progress from A.
2. A logs out offline with unsent items, B logs in, A logs back in: A's items still exist and send.
3. Guest makes progress, then registers: progress appears on the account and the guest DB is removed.
4. App killed while sending: no duplicates after restart.
5. Airplane mode: lessons and review work; missions show the offline state.
6. Logout cancels all scheduled reminders and clears tokens.

---

## 14. Open questions (ask; do not assume)

1. Platform: Flutter native only, or is a PWA also needed?
2. Payments: which system for premium (RevenueCat, native in-app purchase)?
3. Voice missions: turn-based or real-time?
4. Ad network, and whether ads are allowed for minors.
5. Content: languages with full lessons are Spanish, French, German, Japanese, Arabic. "Coming soon": Hindi, Korean, Mandarin, Portuguese (Brazil), IELTS English.
6. Are quests daily, weekly, or permanent? Are streak freezes and the warm-up repair real features?
7. Offline: how many units can free users download? Logout with unsynced data: block, warn, or allow?
8. Guest → account merge: always automatic, or ask on conflict?
9. Analytics and privacy policy for children.
10. Exact design tokens (fonts, spacing, radius, shadows) and screenshots of every main screen.
11. Tablet/iPad designs: none exist in the prototype. Confirm whether the client wants the two-pane layouts in Section 4.3, or just a centered phone layout with a max width on tablets.
12. Phones: lock to portrait, or support landscape too? (Tablets support both.)
13. Minimum supported OS versions and the smallest screen size to support.
