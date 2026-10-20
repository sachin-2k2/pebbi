# Open Questions & Backend/Client Alignment

## 1. Onboarding Setup Flow & Privacy (Step 2: "How old are you?")

### 1.1 Age Band Thresholds & Legal Compliance (COPPA / GDPR-K)
- **Current Client Mock Implementation**:
  - `AgeBand.child`: Age < 13
  - `AgeBand.teen`: Age 13–17
  - `AgeBand.adult`: Age 18+
- **Questions**:
  1. For GDPR-K (Europe) and other jurisdictions (e.g. UK AADC, California AADC), the threshold for child digital consent may be 13, 14, 15, or 16 depending on the country. Should the client adjust the threshold based on locale/country, or does the backend determine this upon synchronization?
  2. For `child` band, is parental email consent (COPPA verifiable consent) required before proceeding?
  3. When an account is registered later from a child profile, what restrictions apply?

### 1.2 Child-Safe Feature Toggles
- **Questions**:
  1. What features specifically must be disabled or altered when `AgeBand == child`?
     - AI Free Talk / AI Missions roleplay (content safety filtering vs disabled)?
     - Speech-to-text / voice recording retention?
     - Ads (personalized ads disabled or all ads replaced with child-safe / ad-free)?
     - Leaderboards / social quests / invite cards?

### 1.3 Preselected Default Year
- **Current Client Mock Implementation**:
  - The prototype shows `2002` preselected as a default constant.
- **Question**:
  - In production, should a default year (e.g. 2002) be preselected, or should the field start empty / unselected with "Continue" disabled until the user explicitly selects a year? (Explicit selection is often recommended for compliance so children cannot accidentally proceed as adults).

### 1.4 Privacy Note Copy by Age Band
- **Current Client Mock Implementation**:
  - Displays: *"All set. We store only the age band, never your birthday."*
- **Question**:
  - Does the copy change if a child or teen year is selected (e.g. informing them that a safe learning mode has been activated)?

### 1.5 Step 1 of 11 Requirements
- **Current Client Mock Implementation**:
  - Placeholder stub at `/onboarding/setup/step-1`.
- **Question**:
  - What is the exact question and UI for Step 1 of 11 (e.g., Native language, Target language, or Age)?

## 2. Onboarding Setup Step 3: Explanation Language ("I speak...")

### 2.1 Progress Header Visibility
- **Current Client Implementation**:
  - Shows `StepProgressHeader(currentStep: 3, totalSteps: 11)` for consistency with AGENTS.md §7.1 and Step 2.
- **Question**:
  - The Step 3 screenshot omitted the top header row (back button, progress bar, `3/11` counter). Should the header be visible across all steps including Step 3, or is it intentionally hidden on language selection?

### 2.2 Translation Review Rollout & Language Catalog
- **Current Client Implementation**:
  - Mocked via `MockLanguageRepository` returning 9 languages, where English has `translationsReviewed: true` and all others have `translationsReviewed: false` (triggering the yellow notice banner).
- **Questions**:
  1. Will the backend provide an API endpoint returning available languages and their `translationsReviewed` status dynamically?
  2. What is the expected rollout schedule for reviewed translations in Spanish, French, Arabic, Hindi, etc.?

## 3. Onboarding Setup Step 4: Target Language ("I want to learn...")

### 3.1 Target Language Matching Native/Explanation Language
- **Observation / Current Implementation**:
  - A user could select Spanish in Step 3 ("I speak Español") and Spanish in Step 4 ("I want to learn Español"). Currently, the app allows this and stores `targetLanguageCode = 'es'`, without blocking progress.
- **Question**:
  - Should the app warn or prevent users from selecting the exact same language for both explanation and learning, or should it allow it (e.g. for advanced native learners or literacy practice)?

### 3.2 Coming Soon Card Tap Behavior
- **Current Client Implementation**:
  - Tapping a coming-soon card (Hindi, Korean, Mandarin Chinese, Portuguese, English) displays a transient snackbar ("Coming soon"), without altering the selection or playing audio.
- **Question**:
  - Is there a planned waitlist / "Notify me when available" email prompt or in-app interest tracker for coming soon languages?

### 3.3 Audio Preview / TTS Source
- **Current Client Implementation**:
  - Utilizes on-device text-to-speech (`flutter_tts`) via `TextToSpeechService` with locale tags (e.g. `es-ES`, `fr-FR`). If a device lacks an installed voice, it fails quietly and displays a subtle non-blocking notice.
- **Question**:
  - Will the backend team or content team provide pre-recorded native audio clips for the "hello" greetings to guarantee consistent native pronunciation across all devices regardless of on-device TTS voice packs?

## 4. Onboarding Setup Step 5: Learning Reasons ("Why are you learning?")

### 4.1 Maximum Selection Limit & 4th Option Feedback
- **Current Client Implementation**:
  - Allows selecting up to 3 reasons. When 3 are selected, tapping a 4th card does not select it and displays a non-blocking message: *"You can pick up to three"*.
- **Question**:
  - Should the UI display this transient message, or should unselected cards be visually dimmed/disabled once 3 are picked?

### 4.2 Minimum Selection Requirement
- **Current Client Implementation**:
  - The design screenshot shows "Continue" enabled even with 0 options selected. The client allows proceeding with 0 to 3 selections (storing whatever set the user picked).
- **Question**:
  - Is picking at least 1 reason mandatory, or is 0 allowed (e.g., defaulting to general/all-round tracks)?

### 4.3 Backpack Dynamic Pill Copy & Sticker Row (RESOLVED)
- **Resolved via Design Screenshot**:
  - Empty: *"Pebbi's backpack is empty"*.
  - With items packed: *"{n} of 3 stickers packed"* (e.g. *"3 of 3 stickers packed"*).
  - Packed stickers: The selected reasons' emoji stickers are rendered in a horizontal row directly beneath the count inside the speech pill.
  - Mascot expression: Pebbi wears the coral backpack straps with happy open eyes.

### 4.4 Track & Mission Mapping Ownership
- **Observation / Current Implementation**:
  - The subtitle states: *"This sets your first track and missions."* The client stores stable reason IDs (`travel`, `work`, `interview`, `study_abroad`, `move_abroad`, `family`, `exams`, `culture`, `just_learning`).
- **Question**:
  - Does the backend resolve which track is active (Everyday, Travel, Work & Interview, Life Abroad, Exams) when syncing user onboarding answers, or will client-side mapping rules be specified?

## 5. Exercise Engine & Placement Quick Check ("Pick the picture")

Plain list of what the exercise screen needs from the backend:
1. **Exercise Question Bank & Payload**:
   - Question schema: `id`, `type` (`pick_picture`, etc.), `prompt`, `audio_text`, `audio_url`, `audio_locale`, `options` array (`id`, `image_ref`, `spoken_label`), `correct_option_id`, `explanation_text`, `correct_answer_text`, `feedback_success_text`.
2. **Audio Delivery**:
   - Will the backend provide pre-recorded native audio URLs (CDN mp3/m4a), or will audio rely on on-device TTS synthesis?
3. **Picture Art Assets**:
   - What asset format will be provided for picture options (SVGs, remote image URLs, Lottie vectors)? (Currently using emoji as provisional visual representation).
4. **Option Shuffling**:
   - Does the backend pre-shuffle option choices, or should the client shuffle distractor positions?
5. **Hint Rules**:
   - Is there a maximum hint limit per question or per session, or are hints unlimited?
   - Do hints affect placement scoring or star awards?
6. **Scoring & Level Calculation**:
   - Does the backend compute the placement level (`little`, `know_a_bit`, `expert`) from submitted attempt results (`firstTryCorrect`, `hintsUsed`, `attempts`), or should the client evaluate this locally?
7. **Redo Queue Persistence**:
   - Are redo attempts stored as separate result records, or does only the final or first-try result sync?
   - Should questions answered wrong during the redo round be re-queued again or terminated after one redo attempt?
8. **Progress Counter in Redo Round**:
   - Should the counter remain `n/8` (reflecting the base placement question count), or expand (e.g. `1/2` for redo)?
## 6. Exercise Type: "What does this mean?" (Choose Meaning)

Plain list of what this exercise type needs from the backend team:
1. **Payload Schema for Text-Choice Exercises**:
   - Fields: `phrase` (target language string), `helper_line` (optional romanization, pinyin, or transliteration for non-Latin scripts like Japanese or Arabic), `text_options` array (`id`, `text`).
2. **Audio Delivery & File Hosting**:
   - Pre-recorded human voice clips vs on-device TTS synthesis (`audio_url` CDN link vs `audio_text` + `audio_locale`).
3. **Autoplay Policy for Listen-First Exercises**:
   - Should listen-first exercises indicate `autoplay: true` in the API payload, or strictly defer to the client's local user setting?
4. **Target Language Direction (RTL)**:
   - For RTL target languages (e.g. Arabic), will the API provide `text_direction: "rtl"` or should the client infer it from the locale code / Unicode script?
5. **Content Verification (Spanish Placement)**:
   - Confirm dummy question copy and distractors with the content team:
     - Q4: "Soy de México" -> "How much does it cost?", "Sparkling water", "I'm from Mexico" (correct: 3)
     - Q5: "¿Cuánto cuesta?" -> "How much does it cost?" (correct: 1), "Where is the bathroom?", "I'm hungry"
     - Q6: "Un café, por favor" -> "A coffee, please" (correct: 1), "The bill, please", "Good night"

## 7. Exercise Type: "Build the sentence" (Tap Word Tiles in Order)

Plain list of what this exercise type needs from the backend team:
1. **Payload Schema for Sentence-Building Exercises**:
   - Fields:
     - `tiles`: Array of candidate word tiles: `[{ id: string, text: string }]`. Tile IDs must be stable and distinct so duplicate words in a sentence are safely disambiguated.
     - `accepted_answers`: Array of accepted tile ID sequences (e.g. `[["q7_tile_ida", "q7_tile_y", "q7_tile_vuelta"]]`) allowing alternative valid word orders.
     - `distractor_tile_ids`: Array of tile IDs that are distractors (e.g. `["q7_tile_a"]`).
     - `prompt`: The source phrase to translate (e.g. "Return ticket").
     - `audio_text` & `audio_locale` / `audio_url`: Target-language phrase audio for feedback and TTS synthesis.
2. **Audio Pronunciation per Tile (RESOLVED)**:
   - **Confirmed with product**: Tapping individual word tiles does NOT play pronunciation audio. Pronunciation audio is played for the full sentence only via feedback/audio button.
3. **Punctuation and Capitalization**:
   - Does the backend bundle punctuation with tiles (e.g. "Ida", "vuelta."), or should punctuation be handled/formatted dynamically by the client?
4. **Distractor Guidelines**:
   - Standard number of distractors per question (1 for placement check, 1–3 for curriculum lessons).
5. **Content Verification (Spanish Placement)**:
   - Confirm dummy questions and distractors with the content team:
     - Q7: "Return ticket" -> Tiles: "A", "y", "Ida", "vuelta" -> Correct: "Ida y vuelta" (Distractor: "A")
     - Q8: "A coffee with milk" -> Tiles: "Un", "café", "con", "leche", "el" -> Correct: "Un café con leche" (Distractor: "el")





## 8. Placement Result Screen & Level Assignment

Plain list of what this screen needs from the backend team:
1. **Scoring & Placement Evaluation Ownership**:
   - Who calculates the learner's recommended level: the client-side app via rules or the backend API?
   - If backend-calculated, what is the API endpoint to submit placement answers (e.g. `POST /api/v1/placement/evaluate`) and what response payload is returned (e.g. `suggested_level`, `first_try_correct`, `praise_phrases`, `awarded_streak`)?
2. **Threshold Boundaries**:
   - Current client mock rules: 7+ first-try correct -> `expert`; 4-6 -> `know_a_bit`; 0-3 -> `little`. What are the final psychometric/scoring thresholds?
3. **Score Chip Visibility Policy ("No scores, no shaming")**:
   - The placement intro promised *"No scores, no shaming"* and *"You never see a fail"*. Should the score chip (`"{n}/8 first try"`) be hidden if the score is low (e.g. <= 3), or shown for all results?
4. **Streak Attribution on Placement Check**:
   - Does completing the placement check award day 1 streak activity (`streak_day: 1`), or does streak start strictly on lesson stops?
5. **Praise Phrases Selection & Order**:
   - When more than 3 questions are answered correctly on the first try, which phrases should be selected, in what priority order?
   - Should tapping praised phrase chips play pronunciation audio?
6. **Level Picker Selection UX**:
   - Does picking a different level immediately collapse the inline picker (current implementation), or stay open until the user taps "Start from here"?
7. **Copy & Grammar Confirmation**:
   - Confirm English phrasing *"You're an Expert learner"* (fixed from mock's *"You're a Expert learner"*) and level descriptions with the product copy team.

## 9. Onboarding Setup Step 7: Daily Goal ("Daily goal")

Plain list of what this step needs from the backend team and product alignment:
1. **User Profile Schema & Daily Goal Field**:
   - What is the field format for storing the daily learning goal in the user profile?
     - Enum string (e.g. `daily_goal_tier: "casual" | "regular" | "serious" | "intense"`), or
     - Integer minutes (e.g. `daily_goal_minutes: 5 | 10 | 15 | 20`).
2. **Preselected Default Confirmation**:
   - Confirm whether "Regular" (10 min/day) should be preselected by default (current prototype behavior), or if explicit user selection is required before enabling the "Continue" action.
3. **Child-Safe Goal Restrictions (AgeBand == child)**:
   - For young learners (under 13 / COPPA compliance), should time limits or caps be enforced (e.g., restricting the open-ended "20+ min a day" Intense tier to promote healthy screen time)?
4. **Minutes vs. Lessons Discrepancy**:
   - The prototype Rewards screen specifies: *"Daily goal: 1 lesson"*, whereas Setup Step 7 sets a goal in minutes (5, 10, 15, 20+ min/day).
   - How should the backend evaluate daily goal progress? Is it calculated via active lesson time, audio engagement duration, or does completing a lesson satisfy the goal?
5. **Daily Goal Reminders & Push Notification Strategy**:
   - Will the backend trigger daily reminder pushes based on the user's selected daily goal and reminder time (Step 8), or is this handled entirely via client-side scheduled local notifications (`flutter_local_notifications`)?
6. **Non-Colour Cue Confirmation**:
   - The design screenshot omits checkmark icons on goal cards. The client currently applies a thicker 2.0 border, typographic bold weight (`FontWeight.w800`), and accessible screen reader semantics as non-colour cues. Confirm if product/design prefers this or an explicit checkmark/pip icon.
7. **Mascot Reaction to Selection**:
   - Confirm if the centered Pebbi mascot should react with dynamic animations or expressions when the user changes between Casual, Regular, Serious, and Intense goals.

## 10. Onboarding Setup Step 8: Daily Reminder ("A gentle nudge?")

Plain list of what this step needs from the backend team and product alignment:
1. **Timezone Package Approval (`timezone` / `tz.TZDateTime`)**:
   - In accordance with AGENTS.md §2.4 (*"Ask before adding any package not on this list"*), we abstracted notification scheduling behind the `NotificationScheduler` interface (`core/services/notification_scheduler.dart`). For production repeating weekly notifications across Daylight Saving Time (DST) transitions, `flutter_local_notifications` requires `tz.TZDateTime` from the `timezone` package. Please confirm approval to add `timezone: ^0.9.4` to `pubspec.yaml`.
2. **First Day of Week & Locale Adaptation**:
   - The design specifies 7 weekday chips `M T W T F S S` (Monday to Sunday, ISO 8601). In regions such as the US, Canada, Japan, and the Middle East, the calendar week customarily begins on Sunday (`S M T W T F S`). Should the weekday chip order adapt to the user's device locale, or remain fixed Monday-to-Sunday across all locales?
3. **Child Quiet Hours & Notification Policy (`AgeBand == child`)**:
   - For young learners (under 13, COPPA/GDPR-K compliance), should the app enforce nighttime quiet hours (e.g. blocking reminders between 8:30 PM and 7:00 AM) or require parental email consent before scheduling notifications?
4. **Client-Side Scheduled Local Notifications vs. Backend Push (APNs / FCM)**:
   - Will daily nudges be triggered via server-side push notifications (FCM / APNs) based on synced user preferences, or managed entirely on-device via local scheduled alarms? If synced to the server, what is the API schema for syncing reminder preferences (e.g. `POST /api/v1/user/reminders` with `reminder_time_utc`, `local_time`, `weekdays`, `timezone`, `fcm_token`)?
5. **Notification Copy & Deep Linking**:
   - What are the approved notification titles and bodies for daily nudges (including randomized gentle variations), and what deep-link payload should be handled when the user taps the notification (e.g., deep-link directly into the next due lesson vs. Home path screen)?
6. **Notification Permission Denied UX**:
   - When notification permission is denied by the user, the app currently displays a non-blocking snackbar notice (*"Notifications are disabled in device settings. You can turn them on anytime in Settings."*) and proceeds smoothly without gating the user. Confirm if product/design prefers an in-app banner or a direct system settings prompt.

## 11. Onboarding Setup Step 9: Meet Pebbi (Accent Colour & First Sticker)

Plain list of what this step needs from the backend team and product alignment:
1. **User Profile Schema for Accent and Starter Sticker**:
   - What is the exact API schema for syncing user preferences from Step 9?
     - `accent_id`: String enum (`"violet" | "green" | "orange" | "blue" | "pink" | "slate"`).
     - `starter_sticker_id`: Nullable string enum (`"wave" | "sparkle" | "wellsaid"`).
2. **Sticker Requirement Policy**:
   - Confirm whether selecting a starter sticker is optional (current client behavior allows continuing without a selection, storing `null`) or mandatory before proceeding to Step 10.
3. **Sticker Inventory & Award Timing**:
   - Is the selected starter sticker unlocked and credited to the user's inventory immediately upon completing onboarding, or upon finishing their first lesson / stop on the path?
4. **App-Wide Accent Colour Scope**:
   - Which specific components across the app should follow the user's chosen accent colour versus the invariant brand purple (`#6C4DF6`)?
     - Currently: `PebbiMascot` body and `ThemeData.colorScheme.primary` update dynamically, while the brand purple identity and mint 3D button (`#2DD4A4`) remain invariant. Please confirm if progress bars, path nodes, or active tabs should also reflect the user accent.
5. **Pre-Recorded Native Audio URLs for First Sentence**:
   - The Hello Pill currently synthesizes native phrase audio via device Text-to-Speech (`TextToSpeechService`). Will the backend provide pre-recorded native speaker audio assets/URLs (e.g. `audio_url`) for the starter greeting phrase across each target language?
6. **Mascot Outfits and Customization**:
   - Confirm that mascot outfits, dynamic mascot reaction animations on tap, and custom mascot naming remain excluded from Step 9 and reserved for later gamification/reward milestones.

## 12. Onboarding Setup Step 10: Premium Offer ("You're all set")

Plain list of what this screen needs from the backend, store APIs, and product alignment:
1. **Subscription Offer & Store API Integration (App Store / Google Play Billing)**:
   - What store product IDs will represent the introductory subscription tier (e.g. `pebbi_premium_monthly_with_trial`)?
   - Introductory offer details required dynamically from store metadata:
     - `trial_days`: Duration of introductory free trial (e.g. 7 days).
     - `formatted_price`: Localized currency string formatted by StoreKit / Play Billing (e.g. "$3.99", "€3.99", "£3.49").
     - `billing_period`: Unit period string (e.g. "month", "year").
     - `trial_eligibility`: Whether the signed-in user or device is eligible for an introductory free trial (Apple/Google introductory price eligibility APIs).
2. **Already-Subscribed / Existing Entitlement Sync**:
   - For users who sign in or restore purchases during onboarding, what endpoint or receipt validation verifies active premium entitlement?
   - When active entitlement is detected, `PremiumRules.shouldShowOffer` should evaluate to `false` and bypass Step 10 directly to Step 11 ("Course ready").
3. **Child Safety & COPPA/GDPR-K Compliance for Age Bands (`AgeBand == child` or teen)**:
   - Store guidelines (Apple Kids Category and Google Play Families Policy) strictly prohibit un-gated subscription upsells, in-app purchases, and ad-based rewards for children under 13, and place restrictions on teens 13–17.
   - Should learners in child/teen bands:
     - Bypass Step 10 entirely, defaulting to the free tier (`selectedPlan = 'free'`), or
     - Require an adult/parental gate (e.g., adult math prompt or parental email verification) before opening the premium options screen?
   - `PremiumRules.shouldShowOffer({AgeBand? ageBand, bool isAlreadyPremium})` is established in the client domain layer to easily gate this once compliance rules are approved.
4. **Rewarded Ad Network for 24-Hour Free Pass (`canWatchAdForFreeDay`)**:
   - The caption text mentions *"Or watch a short ad for a free day."*
   - Which ad network will be integrated (e.g. Google Mobile Ads AdMob / AppLovin / Unity Ads)?
   - How will the 24-hour pass entitlement be granted, validated, and stored on the backend (e.g. Server-Side Verification / SSV callbacks from the ad network)?
   - Are rewarded ads permitted for free users in all jurisdictions?
5. **Store Compliance & Placement of Mandatory Subscription Terms**:
   - Both Apple (App Store Review Guideline 3.1.2) and Google Play Subscription Policy require functional disclosure of subscription terms:
     - Recurring billing price and frequency.
     - Trial duration and exact date first charge occurs.
     - Cancellation instructions and link to Apple/Google subscription management.
     - Clickable links to Terms of Service and Privacy Policy.
   - **Recommended Architecture**:
     - Step 10 is an informational teaser with a soft CTA button ("See premium options") and contains no direct purchase trigger or payment processing.
     - Therefore, mandatory legal terms, cancellation terms, TOS, and Privacy Policy links belong directly on the `/premium/options` checkout screen/sheet adjacent to the actual purchase buttons.
     - Please confirm product and legal agreement on this separation.
6. **Dynamic Benefit Lines per Plan**:
   - The check-list currently lists 3 static localized benefits:
     - *"Every unit and stop, from today"*
     - *"All five languages on one streak"*
     - *"Unlimited missions and no ads"*
   - Will the backend provide dynamic benefit highlights depending on A/B test experiments, region, or user intent (e.g. highlighting travel missions for users who selected Travel in Step 5)?
7. **Progress Header (10/11) on Step 10**:
   - The design screenshot omits the top header row. The client currently displays `StepProgressHeader(currentStep: 10, totalSteps: 11)` to maintain consistent navigation, back button access, and step awareness. Please confirm whether the design intends to hide the header bar on Step 10.

## 13. Onboarding Setup Step 11: Path Ready ("Your path is ready")

Plain list of what this screen needs from the backend and product alignment:
1. **Curriculum Generation & First Stop Placement**:
   - When onboarding completes, does the backend generate the personalized learning path (units, lessons, and stops) synchronously or asynchronously?
   - What API endpoint receives the finalized onboarding profile and returns the user's initial path node (`POST /api/v1/onboarding/complete` returning `first_lesson: { id, unit_number, lesson_number, title, estimated_minutes }`)?
2. **Offline Content Pack & Audio Pre-Caching**:
   - The preparation sequence displays *"Headphones on — audio is ready"*.
   - What size is the initial Unit 1 asset bundle (audio files, illustrations, exercise metadata) required for offline-first readiness?
   - Will the backend provide a single bundled archive (e.g. `unit_1_assets.zip`) for quick background extraction, or individual asset URLs?
3. **Task Blocking Rules for "Start lesson 1"**:
   - Currently, if any blocking task (audio download) fails, the "Start lesson" CTA remains disabled and offers an inline "Retry".
   - If an asset download fails due to offline/poor connectivity, should the app allow the user to proceed anyway with a degraded/text-only mode (e.g., "Continue anyway" after repeated retries)?
4. **Starter Sticker & Inventory Crediting**:
   - *"Sticker book started"* is confirmed on this screen.
   - What endpoint credits the user's selected starter sticker (from Step 9) into their persistent inventory?
5. **Guest Account Creation vs. Sign-In Prompt Timing**:
   - The client creates a local guest profile (`guest_<id>`) on this step.
   - At what exact point should the guest user be prompted to register or connect OAuth (e.g., when tapping "Start lesson 1", upon finishing the first lesson, or on the home path screen)?
6. **Streak Integrity**:
   - Per AGENTS.md §9, finishing onboarding is **not** an active streak day (streaks represent actual lesson or mission completion). Confirm that the backend does not increment streak counters simply for finishing onboarding.
7. **Emoji Platform Rendering**:
   - 🎧 Headphones: Apple renders silver over-ear; Android (Google Noto Color) renders black/white over-ear.
   - 👋 Waving hand: Apple renders classic yellow hand with motion lines; Android renders yellow wave.
   - 🎙️ Microphone: Apple renders silver vintage microphone on stand; Android renders black/silver studio microphone.
   - Emojis are excluded from screen reader semantics to ensure clean accessibility.
8. **Progress Header (11/11) on Step 11**:
   - The design screenshot omits both the top progress bar and the back button. Confirm that the finalized screen is intentionally full-screen without a top header.

## 14. Auth Screen: Login ("Welcome back")

Plain list of what this screen needs from the backend team and product alignment:
1. **Authentication API Endpoints & Contract**:
   - `POST /api/v1/auth/login`: Accepts `{ email, password }`, returns `{ user_id, access_token, refresh_token, expires_in, profile }`.
   - `POST /api/v1/auth/google`: Accepts Google ID token / auth code, returns session tokens.
   - `POST /api/v1/auth/refresh`: Accepts `{ refresh_token }`, returns new access and refresh tokens.
   - `POST /api/v1/auth/logout`: Revokes refresh token and unregisters device push token.
2. **Apple Sign-In Requirement (App Store Review Guideline 4.8)**:
   - Apple requires "Sign in with Apple" to be provided on iOS whenever third-party social logins (e.g. Google) are offered. The design shows only Google.
   - Will the backend team support Apple Sign-In (`POST /api/v1/auth/apple`) for iOS submissions, or will social login be Android-only initially?
3. **Rate Limiting & Lockout Rules (`tooManyAttempts`)**:
   - What is the threshold for brute-force protection (e.g., 5 consecutive failed attempts triggering a 15-minute cooldown)?
   - Does the backend return a `Retry-After` header or `retry_after_seconds` integer in the error response payload so the client can show an accurate countdown?
4. **Guest Progress Migration & Conflict Rules**:
   - What is the endpoint for merging guest progress into an authenticated account (`POST /api/v1/auth/merge-guest` with `{ guest_id, user_id }`)?
   - How should conflicts be resolved if both the guest session and authenticated user account have existing progress (e.g. guest completed Unit 1 Spanish, but account has Unit 3 French)?
5. **Password Retention on Error**:
   - When an invalid credentials error occurs, should the password field be cleared immediately or preserved for user editing? (Currently preserved with `TODO(question)`).
6. **Close / Back Dismissal Behavior**:
   - Both Login and Register design screenshots omit a close/back button in the top header. The app relies on system back gesture and the bottom switch links to navigate.

## 15. Auth Screen: Register ("Create your account")

Plain list of what this screen needs from the backend team and product alignment:
1. **Registration API Endpoint & Contract**:
   - `POST /api/v1/auth/register`: Accepts `{ email, password }` (or `{ email, password, age_band, parent_email }`).
   - Returns `{ user_id, access_token, refresh_token, expires_in, profile }`.
2. **Password Policy**:
   - The design does not specify a password policy. The client enforces a length-based rule (minimum 8 characters, maximum 72 characters) without arbitrary character complexity (favouring length and password-manager compatibility per NIST guidance).
   - What is the authoritative backend password policy? Are there special character, number, or breached-password dictionary checks?
3. **Account Enumeration & "Email Already Registered"**:
   - Displaying *"This email is already registered"* reveals whether an account exists, which can be an account enumeration vulnerability.
   - For security, the mock currently presents a neutral message (*"Check your inbox to continue"*).
   - What is the security guidance and exact messaging the backend team prefers?
4. **Email Verification**:
   - Is email verification mandatory before accessing the learning path, or can the user start learning immediately with an unverified account banner?
   - What is the verification flow (magic link, 6-digit OTP code, or email link)?
5. **Child Safety, COPPA, and GDPR-K**:
   - How should child accounts (`AgeBand.child` or age < 13/16) be handled during registration?
   - Is verifiable parental consent (COPPA) required before account creation, or are children restricted to offline guest profiles?
   - May children use Google Sign-In?
6. **Unknown Age Band Fallback**:
   - If a user registers without completing onboarding (or if age band is uncollected), should registration default to adult, prompt for birth year/band, or require explicit parental declaration?
7. **Terms of Service & Privacy Policy Consent**:
   - The design shows no legal consent text or checkbox.
   - What legal consent wording, version tracking (e.g. `terms_version_accepted: "2026-01"`), and UI mechanism (clickwrap vs browsewrap) are required by legal counsel?
8. **Guest Progress Migration**:
   - When a guest user registers, their local data (stars, streak, learned phrases, stickers, settings) is migrated via `mergeGuestProgress`.
   - What is the backend contract for migration (`POST /api/v1/auth/merge-guest`), and how are merge conflicts handled?

## 16. Auth Screen: Forgot Password ("Reset password")

Plain list of what this screen needs from the backend team and product alignment:
1. **Password Reset API Endpoint & Contract**:
   - `POST /api/v1/auth/forgot-password`: Accepts `{ email: string }`.
   - Security rule: Must always return HTTP 200 / success with an identical response duration, regardless of whether the email exists in the database, to protect against account enumeration.
2. **Rate Limiting & Cooldown Window**:
   - What rate limits apply to password reset requests (e.g., max 3 requests per IP/email per hour)?
   - Does the API return a `Retry-After` header or `retry_after_seconds` integer when rate-limited?
   - The client currently enforces a local 60-second cooldown (`PasswordResetCooldown.defaultCooldownSeconds = 60`) before allowing a resend. What should the authoritative client-side cooldown be?
3. **Reset Token Lifespan & Invalidation Rules**:
   - How long is the password reset link valid (e.g., 15 minutes, 1 hour, 24 hours)?
   - If the user requests a second reset link via "Resend link", is the previous token immediately invalidated, or remain valid until expiration?
   - Is the reset token strictly single-use?
4. **Google-Only Accounts (Passwordless)**:
   - If an account was registered exclusively via Google OAuth and has no password, how should the backend respond?
   - Recommendation: Send an email notifying the user *"You sign in to Pebbi with Google. You can continue using Google Sign-In or set up a password here: [link]"*. The client maintains the neutral success message regardless.
5. **Privacy in Confirmation View**:
   - The confirmation card displays the email entered by the user (*"If an account exists for alex@example.com, we've sent a link..."*) to help users quickly spot typos. Confirm whether displaying the full typed email is approved or if masking is required.
6. **Signed-in User Reset / Change Password**:
   - If opened from Settings by a signed-in user, should it trigger the same external email link flow or navigate to an in-app current-password verification endpoint (`POST /api/v1/auth/change-password`)?
7. **Label Styling Inconsistency**:
   - The screenshot specifies regular-weight "Email address" (`FontWeight.normal`), whereas Login and Register use bold "Email" (`FontWeight.w700`). Confirm whether this difference is intended by the design team.
8. **Deep Linking Infrastructure (Flutter Engine & Server Hosting)**:
   - Flutter routing is managed via `go_router` (`/reset-password?token=...`). **No additional Flutter packages are required.**
   - Requirements from the web/backend team:
     - **Android App Links**: Host Digital Asset Links JSON at `https://<domain>/.well-known/assetlinks.json` containing the app's package name and SHA-256 certificate fingerprint.
     - **iOS Universal Links**: Host Apple App Site Association JSON at `https://<domain>/.well-known/apple-app-site-association` with the app's Team ID and Bundle ID.

## 17. Main Screen: Home Path ("Path" Tab)

Plain list of what this screen needs from the backend team and product alignment:
1. **Curriculum Rail Schema & API Contract (`GET /api/v1/path/tracks/{track_id}`)**:
   - What is the endpoint schema for retrieving the units, nodes, and progress on the learning path?
   - Expected payload:
     - `units`: Array of units (`id`, `unit_number`, `title`, `track_id`, `is_free`, `is_locked`, `guidebook_id`).
     - `nodes`: Array of stops per unit:
       - `id`: Unique stop identifier.
       - `type`: Enum (`"lesson" | "review" | "mission" | "chest"`).
       - `title`: Localized stop title (e.g., "Say hello", "Order coffee").
       - `status`: Enum (`"done" | "current" | "locked"`).
       - `lock_reason`: Enum (`"none" | "progress" | "premium"`).
       - `stars_earned`: Integer (0..3) representing stars rating on completed stops.
       - `is_next`: Boolean flag identifying the immediate next stop to complete.
2. **Dynamic Rail Geometry Ownership**:
   - The winding rail follows a zigzag layout. Does the backend prescribe horizontal offset fractions/curves per node, or does the client calculate this deterministically via the client-side fraction algorithm `[0.50, 0.50, 0.72, 0.60, 0.42, 0.32]` with width clamping and RTL horizontal inversion?
   - (Recommendation: Client-side mathematical calculation to adapt smoothly to arbitrary device widths and window resize events without network overhead).
3. **Locked Node Test-Out Challenge Rules**:
   - When tapping a locked node or locked unit header, the sheet offers *"Test out (8 questions)"*.
   - What endpoint serves and grades the test-out challenge (`POST /api/v1/units/{unit_id}/test-out`)?
   - What are the passing criteria (e.g., 7 of 8 correct, or 80%)?
   - Does passing a test-out challenge unlock all preceding nodes in that unit and credit full stars (e.g. 15 stars per AGENTS.md §9), or just mark the unit unlocked?
4. **Track Progression & Content Availability**:
   - The prototype includes track chips: Everyday, Travel, Work & Interview, Life Abroad, Exams.
   - Per AGENTS.md §7.3: *"shown only if content exists"*.
   - Does the backend return which tracks have published content dynamically per target language (`GET /api/v1/tracks?language=es`), and how is progress shared across tracks?
5. **Due Review Counter & Spaced-Repetition Sync**:
   - The Due Strip displays:
     - *"Start your first lesson to build review phrases"* (new user with 0 saved phrases)
     - *"Nothing due — your phrases are strong"* (user has learned phrases, none currently due)
     - *"{n} phrases due for review"* (with a 1-tap "Review" link)
   - What is the sync contract for spaced repetition review schedules (`GET /api/v1/review/due-count`)?
6. **House Ad vs Ad Network Serving**:
   - Free users see an ad card: *"Learn faster without interruptions"* with a button to *"Remove ads · Premium {price}"*.
   - Will this banner serve internal house promotion ads (promoting Pebbi Premium with dynamic store pricing), or integrate standard banner ads (e.g. AdMob Adaptive Banner)?
   - Under COPPA/GDPR-K, child profiles (`AgeBand.child`) must have third-party advertising completely suppressed (`AdRules.shouldShowAds` strictly enforces this on the client).

## 18. Missions & AI Role-Play Screen Specifications

### 18.1 What the Missions Screen Needs from the Backend (Plain List)
1. **Mission Catalog & Taxonomy**:
   - Available categories list (e.g. `Everyday`, `Travel`, `Health`, `Money`, `Social`).
   - List of role-play scenes / missions per target language:
     - `id`: Unique mission identifier (e.g. `order_coffee`).
     - `category_ids`: Array of category IDs (a mission can belong to multiple categories).
     - `title`: Localized scene title (e.g. "Order a coffee").
     - `character_name`: Name of the AI conversation partner (e.g. "Lucía").
     - `character_role`: Role of the AI partner (e.g. "barista", "receptionist").
     - `duration_minutes`: Estimated minutes for the rehearsal (e.g. 5).
     - `difficulty`: Integer rating from 1 to 3.
     - `emoji`: Visual icon emoji representing the scene.
     - `is_premium`: Boolean flag indicating whether the mission is locked behind Premium.
2. **Per-User Mission Status & History**:
   - Status per mission for the authenticated user (`"new" | "in_progress" | "done"`).
   - Stars or scores earned (if applicable; debrief scores 4 dimensions: understood, clear, polite, goals hit).
   - User isolation: Guest progress migrated on registration; users never see another user's mission status.
3. **Today's Featured Mission Selection**:
   - Daily highlighted mission object (selected mission, optional reason/badge, and whether completed today).
   - Fallback behavior when all daily missions have been completed.
4. **Free Tier Quotas & Limits**:
   - Clarify the exact role-play mission limits for free learners (e.g., N missions per day, 1 free mission per week, or 24-hour unlock via rewarded video ad).
   - Server-side error payload when a free user exceeds their allowed mission quota (`limit_reached`).
5. **Target Language Fallbacks**:
   - If the user selects a language that does not yet have specialized cultural character names/roles, what is the server's fallback response (e.g., standard universal scenes)?
6. **Child Safety & Conversational Guardrails (COPPA / GDPR-K)**:
   - Confirm child-safe restrictions for open-ended AI conversational role-play (`shouldShowMissions` and `shouldAllowFreeTalk`).
   - Retention rules for child audio recordings / transcripts.

## 19. Emergency Phrasebook Specifications & Safety Rules

### 19.1 What the Emergency Phrasebook Needs from the Backend (Plain List)
1. **100% Offline Delivery & Native Human Review**:
   - The emergency phrasebook is life-critical and must function completely offline (zero latency, zero network dependency).
   - What is the content approval and distribution pipeline for native human-reviewed phrases?
   - Machine translation is strictly banned for emergency phrases. Confirm which target languages have certified native-speaker approvals before client release (currently Spanish is reviewed; French, German, Japanese, and Arabic stubs are unreviewed).
2. **Grammatical Gender & Deictic Contexts**:
   - In languages with grammatical gender (e.g., Spanish, French, Arabic), adjectives agree with speaker gender:
     - Spanish: *"Estoy perdido"* (masculine) vs *"Estoy perdida"* (feminine).
     - Spanish: *"Soy alérgico a esto"* (masculine) vs *"Soy alérgica a esto"* (feminine).
   - Alternatively, gender-neutral phrasing can be adopted (e.g., *"Tengo una alergia severa a esto"*, *"No sé dónde estoy"*).
   - Confirm whether the content team prefers gender-neutral phrasings or user-profile-driven gendered variants.
3. **Explanation Language Matrix**:
   - Phrases must be explained in the learner's explanation language (e.g. English, French, Japanese, Arabic) while target phrases are rendered in the target language.
   - What is the fallback policy when a user's native explanation language is unsupported? (Current client implementation: fallback to English).
4. **Pre-recorded Native Audio vs Device TTS**:
   - On-device TTS voice packages may be missing on low-end or offline devices without network access.
   - Will the backend bundle or pre-cache compressed native human audio recordings (`.aac` or `.opus`, ~15KB per phrase, ~120KB total) during initial download or first onboarding setup?
5. **Strict No-Emergency-Number Policy**:
   - The app explicitly displays: *"This phrasebook is for quick communication in common urgent situations. It does not replace local emergency services. In a true emergency, call the local emergency number."*
   - Confirm that Pebbi does **not** attempt to auto-dial or look up local dispatch numbers (911/112/999/119) due to legal liability, geolocation spoofing, and SIM roaming variations.





