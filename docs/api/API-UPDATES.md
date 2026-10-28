# API-UPDATES.md: newer answers from the backend team

**Status:** These answers came as a plain-text chat message from the backend developer, sent after the first API document (`TUTOTOCO-BACKEND-APIS.md`). They are NOT an official specification and contain NO JSON field names for the new endpoints.

**Precedence:** where this file and `TUTOTOCO-BACKEND-APIS.md` differ, THIS FILE WINS. Anything marked ASSUMED or UNKNOWN below must be treated as a question for the backend, not as a fact.

When the backend sends a real OpenAPI file or an updated document, replace both files and re-check everything against it.

---

## 1. Changes compared with the first document

| Topic | First document | Now (this file) |
|---|---|---|
| `reminder_days` | letters `["M","T","W","T","F","S","S"]` | full day names (`"Monday"`, `"Tuesday"` ...) OR integers 1 to 7 (1 = Monday, 7 = Sunday) |
| `accent_color` | hex, example `#7C3AED` | ids: `violet`, `green`, `orange`, `blue`, `pink`, `slate` |
| Register fields | a smaller set | accepts ALL onboarding fields: `age_band`, `learning_goals`, `daily_goal`, `reminder_time`, `reminder_days`, `accent_color`, `first_sticker`, `current_level`, `suggested_level`, `placement_skipped`, `placement_score`, `placement_total` |
| Login response | user with only `language_pref` | the SAME full user object as `verify-otp`, with all onboarding settings and `onboarding_done: true` |
| Profile endpoints | none | `GET /api/me` and `PATCH /api/me` (for the Settings screen: level, language, reminders, accent, goals) |
| Language lists | none | `GET /api/languages/native` and `GET /api/languages/learn?native_language=xx` (new, see section 2) |
| Placement submit | said the level is saved | `POST /api/placement/submit` does NOT save to the database. It calculates score and level on the fly and returns them. The app keeps the result locally and sends it in `POST /api/auth/register` |
| Sign-up | not specified | mandatory before Lesson 1, so all progress is tied to an account |

## 2. Language lists

- Both are PUBLIC (no auth), with ETag and Cache-Control headers for offline caching.
- `GET /api/languages/native`: the spoken (explanation) languages: Malayalam, Hindi, Tamil, Telugu, Kannada, Spanish, Arabic, and others. Each has `translations_reviewed`; `false` means the translations are AI-translated at launch.
- `GET /api/languages/learn?native_language=ml`: returns English (`en`) as `available` with `has_lessons: true` and `has_placement: true`. Spanish, French and German are `coming_soon` with `has_lessons: false`.
- If `native_language` equals `learning_language`, the backend returns a 400 error ("Spoken language and learning language cannot be the same").
- UNKNOWN: the exact JSON field names and shape of these two responses. UNKNOWN: whether English is also in the native list.

## 3. Placement (quick check)

- `GET /api/placement/questions`: fixed 8 questions (difficulty A1, A2, B1).
- If there is no quiz for a language it returns `{"available": false, "default_level": "starter"}`. It never silently falls back to another language.
- `POST /api/placement/submit`: does not save anything on the server (see section 1).

## 4. Sign-up data and storage

- Register stores the onboarding data temporarily together with the OTP in `otp_records`. If the OTP expires, the data is cleared and the user can register again.
- `POST /api/auth/verify-otp` and `POST /api/auth/login` return the same full user object (all onboarding settings, `onboarding_done: true`).
- Steps 1 to 6 (onboarding and the quick check) happen on the phone with no account. Sign-up is mandatory at the next step, before starting Lesson 1. There is no guest session on the server.

## 5. Allowed values (confirmed)

| Field | Values |
|---|---|
| `age_band` | `"13-17"`, `"18-24"`, `"25-34"`, `"35-44"`, `"45-54"`, `"55+"` (minimum registration age is 13) |
| `learning_goals` | `travel`, `work`, `interview`, `study_abroad`, `move_abroad`, `family`, `exams`, `culture`, `just_learning` |
| `daily_goal` | `casual`, `regular`, `serious`, `intense` (5, 10, 15 and 20 minutes) |
| `level` | `starter`, `know_a_bit`, `expert` |
| `accent_color` | `violet`, `green`, `orange`, `blue`, `pink`, `slate` |
| `first_sticker` | `first_hello`, `little_spark`, `well_said`, `explorer`, `star` |
| `reminder_days` | full day names or integers 1 to 7 (1 = Monday, 7 = Sunday) |

## 6. Still UNKNOWN or not confirmed

Treat each as a question for the backend. Do not invent endpoints or fields for them.

- Exact JSON for: language lists, `GET /api/me`, `PATCH /api/me` (which fields it accepts), the register request and response.
- Resend code, password reset (request and confirm), logout, token lifetime and refresh, Google or Apple sign-in, delete account.
- Which register fields are required (`display_name`, `age_band`, languages) and whether the server rejects a missing `age_band`.
- Password rules (the first document said 8+ characters, one uppercase letter, one number).
- Whether English is also available as a spoken language, what an English speaker can learn, and when other courses arrive.
- Which English accent the audio and quiz use, and whether recorded audio will exist.
- How the 13+ age rule is enforced when the app only collects a birth year, and what children aged 13 to 17 may do.
- Everything from the first document's gaps that the backend has not answered: lesson answers checked on the server (offline), question types other than `pick_meaning`, hints, stars versus XP, failed lessons, tracks and units, rewards, review, missions, subscriptions, stable error codes, idempotency for submits.
