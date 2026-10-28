# API-V2.md: JSON samples from the backend team

**Status:** Copied word for word from the document the backend developer sent after `TUTOTOCO-BACKEND-APIS.md` and `API-UPDATES.md`. The original section numbers ("6.", "2.", "3." ...) are kept as received. It is NOT an official specification: fields not shown in a sample are unknown.

**Precedence:** this file is the highest priority. Where it differs from `API-UPDATES.md` or `TUTOTOCO-BACKEND-APIS.md`, this file wins.

---

## 6. Get "I Speak" List (Native Language)

Fetch the list of native languages the user speaks for explanations and translations.

- **Method:** GET
- **URL:** `/api/languages/native`
- **Auth:** None (Public)
- **Headers:** `Accept: application/json`

**Response (200 OK):**

```json
[
  {
    "code": "ml",
    "name": "മലയാളം",
    "english_name": "Malayalam",
    "script_glyph": "മ",
    "translations_reviewed": false
  },
  {
    "code": "hi",
    "name": "हिन्दी",
    "english_name": "Hindi",
    "script_glyph": "अ",
    "translations_reviewed": false
  },
  {
    "code": "ta",
    "name": "தமிழ்",
    "english_name": "Tamil",
    "script_glyph": "த",
    "translations_reviewed": false
  },
  {
    "code": "te",
    "name": "తెలుగు",
    "english_name": "Telugu",
    "script_glyph": "తె",
    "translations_reviewed": false
  },
  {
    "code": "kn",
    "name": "ಕನ್ನಡ",
    "english_name": "Kannada",
    "script_glyph": "ಕ",
    "translations_reviewed": false
  },
  {
    "code": "es",
    "name": "Español",
    "english_name": "Spanish",
    "script_glyph": "Ñ",
    "translations_reviewed": false
  },
  {
    "code": "ar",
    "name": "العربية",
    "english_name": "Arabic",
    "script_glyph": "ع",
    "translations_reviewed": false
  },
  {
    "code": "fr",
    "name": "Français",
    "english_name": "French",
    "script_glyph": "Ç",
    "translations_reviewed": false
  },
  {
    "code": "de",
    "name": "Deutsch",
    "english_name": "German",
    "script_glyph": "Ä",
    "translations_reviewed": false
  },
  {
    "code": "en",
    "name": "English",
    "english_name": "English",
    "script_glyph": "A",
    "translations_reviewed": true
  }
]
```

**Note:** The response contains `ETag: "peb-native-v1"` and `Cache-Control: public, max-age=86400` headers so the mobile app can cache it offline.

---

## 2. Get "I Want to Learn" List

Fetch the list of languages available to learn. Returns active languages and greyed-out `coming_soon` languages.

- **Method:** GET
- **URL:** `/api/languages/learn?native_language=ml`
- **Auth:** None (Public)
- **Query Parameters:** `native_language` (optional, string): e.g. `ml`, `hi`, `en`

**Response (200 OK):**

```json
[
  {
    "code": "en",
    "name": "English",
    "english_name": "English",
    "script_glyph": "A",
    "difficulty": 1,
    "learners_count": 52000000,
    "status": "available",
    "has_lessons": true,
    "has_placement": true,
    "hello_text": "Hello",
    "tts_locale": "en-US"
  },
  {
    "code": "es",
    "name": "Español",
    "english_name": "Spanish",
    "script_glyph": "Ñ",
    "difficulty": 1,
    "learners_count": 42000000,
    "status": "available",
    "has_lessons": false,
    "has_placement": true,
    "hello_text": "Hola",
    "tts_locale": "es-ES"
  },
  {
    "code": "fr",
    "name": "Français",
    "english_name": "French",
    "script_glyph": "Ç",
    "difficulty": 2,
    "learners_count": 28000000,
    "status": "coming_soon",
    "has_lessons": false,
    "has_placement": false,
    "hello_text": "Bonjour",
    "tts_locale": "fr-FR"
  },
  {
    "code": "de",
    "name": "Deutsch",
    "english_name": "German",
    "script_glyph": "Ä",
    "difficulty": 2,
    "learners_count": 16000000,
    "status": "coming_soon",
    "has_lessons": false,
    "has_placement": false,
    "hello_text": "Hallo",
    "tts_locale": "de-DE"
  },
  {
    "code": "ar",
    "name": "العربية",
    "english_name": "Arabic",
    "script_glyph": "ع",
    "difficulty": 3,
    "learners_count": 19000000,
    "status": "coming_soon",
    "has_lessons": false,
    "has_placement": false,
    "hello_text": "مرحبا",
    "tts_locale": "ar-SA"
  }
]
```

---

## 3. Quick Check Intro Message

- **Method:** GET
- **URL:** `/api/placement/intro?native_language=ml`
- **Auth:** None (Public)
- **Query Parameters:** `native_language`: User's chosen native language code (e.g. `ml`, `hi`)

**Response (200 OK):**

```json
{
  "pebbi_says": "ഹലോ, സുഹൃത്തേ! 👋 നിങ്ങൾക്ക് എത്രമാത്രം അറിയാമെന്ന് നോക്കാം. സമ്മർദ്ദമില്ല — ആസ്വദിക്കൂ! 😎",
  "subtitle": "8 പെട്ടെന്നുള്ള ചോദ്യങ്ങൾ · ഏകദേശം 2 മിനിറ്റ് · വിജയത്തിൽ അവസാനിക്കുന്നു"
}
```

---

## 4. Get Placement Test Questions

Fetches the 8 placement questions.

- **Method:** GET
- **URL:** `/api/placement/questions?target_language=es&native_language=ml`
- **Auth:** None (Public)
- **Query Parameters:**
  - `target_language`: The language the user wants to learn (e.g. `en` or `es`)
  - `native_language`: The language the user speaks (e.g. `ml`)

**Response (200 OK, when quiz exists):**

```json
{
  "available": true,
  "total": 8,
  "questions": [
    {
      "id": "67137f6a2b9a1a0012345678",
      "sort_order": 1,
      "difficulty": "A1",
      "question_text": "ഇതാ നിങ്ങൾക്ക്! 🎁",
      "target_phrase": "Aquí tiene",
      "options": [
        { "emoji": "🤝", "label": "ഇതാ നിങ്ങൾക്ക്!", "is_correct": true },
        { "emoji": "👋", "label": "വിട!", "is_correct": false },
        { "emoji": "🙅", "label": "ഒരു കാരണവശാലും ഇല്ല!", "is_correct": false },
        { "emoji": "🤷", "label": "എനിക്കറിയില്ല", "is_correct": false }
      ],
      "fun_fact": "സ്പെയിനിൽ നിങ്ങൾ ഇത് ദിവസവും കേൾക്കും!",
      "pebbi_correct": "വളരെ നല്ലത്! 🔥 നിങ്ങൾ മികച്ച തുടക്കത്തിലാണ്!",
      "pebbi_wrong": "ക്ഷമിക്കണം! 'Aquí tiene' എന്നത് വെയിറ്റർമാർ ഭക്ഷണം വിളമ്പുമ്പോൾ പറയുന്നതാണ്! 🍽️",
      "pebbi_warning": null
    }
  ]
}
```

**Response (200 OK, when quiz does not exist for this language):**

```json
{
  "available": false,
  "message": "ഉടൻ വരുന്നു! തുടക്കക്കാരൻ ലെവലിൽ ആരംഭിക്കുന്നു 🌱",
  "default_level": "starter"
}
```

---

## 5. Submit Placement Test

Calculates the score and suggested level on the fly. Does not require a user account and does not write to the DB. The mobile app keeps the result and sends it during registration.

- **Method:** POST
- **URL:** `/api/placement/submit`
- **Auth:** None (Public)

**Payload (Body):**

```json
{
  "native_language": "ml",
  "answers": [
    { "question_id": "67137f6a2b9a1a0012345678", "chosen_emoji": "🤝" },
    { "question_id": "67137f6a2b9a1a0012345679", "chosen_emoji": "☕" },
    { "question_id": "67137f6a2b9a1a0012345680", "chosen_emoji": "👋" }
  ]
}
```

**Response (200 OK):**

```json
{
  "score": 3,
  "total": 3,
  "score_pct": 100,
  "level": "expert",
  "identity": "Star 🌟",
  "emoji": "🌟",
  "message": "നിങ്ങൾ ഒരു താരമാണ്! നമുക്ക് തുടങ്ങാം! 🌟",
  "estimated_note": "ഈ ചെറിയ ക്വിസ് അടിസ്ഥാനമാക്കിയുള്ള കണക്കാക്കിയ ആരംഭ പോയിന്റ്"
}
```

---

## 6. Sign-Up Step 1: Register (Sends Email OTP)

Validates the user account details, checks for duplicate email, ensures `native_language != learning_language`, temporarily holds all onboarding choices, and emails a 6-digit OTP code.

- **Method:** POST
- **URL:** `/api/auth/register`
- **Auth:** None (Public)

**Payload (Body):**

```json
{
  "email": "user@example.com",
  "password": "Password123",
  "display_name": "Farsana",
  "native_language": "ml",
  "learning_language": "en",
  "current_level": "starter",
  "suggested_level": "starter",
  "placement_skipped": false,
  "placement_score": 6,
  "placement_total": 8,
  "age_band": "18-24",
  "learning_goals": ["travel", "work"],
  "daily_goal": "regular",
  "reminder_time": "19:00",
  "reminder_days": ["Monday", "Wednesday", "Friday"],
  "accent_color": "violet",
  "first_sticker": "first_hello"
}
```

**Response (200 OK):**

```json
{
  "message": "Verification code sent to user@example.com",
  "expires_in": "10 minutes"
}
```

**Possible Error Responses:**

- 400 Bad Request: `{"detail": "Spoken language and learning language cannot be the same"}`
- 400 Bad Request: `{"detail": "Email already registered. Please log in."}`
- 400 Bad Request: `{"detail": "Password must have: at least 8 characters, at least 1 uppercase letter, at least 1 number"}`

---

## 7. Sign-Up Step 2: Verify OTP (Creates Account)

Verifies the 6-digit code, creates the user account in MongoDB with all onboarding data, and returns the JWT Bearer token + user profile.

- **Method:** POST
- **URL:** `/api/auth/verify-otp`
- **Auth:** None (Public)

**Payload (Body):**

```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Response (200 OK):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "671cc85341f237bf81d2a191",
    "display_name": "Farsana",
    "email": "user@example.com",
    "native_language": "ml",
    "learning_language": "en",
    "current_level": "starter",
    "level": "starter",
    "suggested_level": "starter",
    "placement_skipped": false,
    "placement_score": 6,
    "placement_total": 8,
    "age_band": "18-24",
    "learning_goals": [
      "travel",
      "work"
    ],
    "daily_goal": "regular",
    "reminder_time": "19:00",
    "reminder_days": [
      "Monday",
      "Wednesday",
      "Friday"
    ],
    "accent_color": "violet",
    "first_sticker": "first_hello",
    "onboarding_done": true
  }
}
```

**Possible Error Responses:**

- 400 Bad Request: `{"detail": "Invalid OTP. Please check and try again."}`
- 400 Bad Request: `{"detail": "OTP expired. Please request a new one."}`

---

## 8. Log In (Existing Users)

Logs in a returning user and returns the JWT Bearer token and the same full user profile.

- **Method:** POST
- **URL:** `/api/auth/login`
- **Auth:** None (Public)

**Payload (Body):**

```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response (200 OK):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "671cc85341f237bf81d2a191",
    "display_name": "Farsana",
    "email": "user@example.com",
    "native_language": "ml",
    "learning_language": "en",
    "current_level": "starter",
    "level": "starter",
    "suggested_level": "starter",
    "placement_skipped": false,
    "placement_score": 6,
    "placement_total": 8,
    "age_band": "18-24",
    "learning_goals": [
      "travel",
      "work"
    ],
    "daily_goal": "regular",
    "reminder_time": "19:00",
    "reminder_days": [
      "Monday",
      "Wednesday",
      "Friday"
    ],
    "accent_color": "violet",
    "first_sticker": "first_hello",
    "onboarding_done": true
  }
}
```

**Possible Error Response:**

- 401 Unauthorized: `{"detail": "Invalid email or password"}`

---

## 9. Get Current User Profile (Settings Screen)

Fetches the latest profile and settings for the logged-in user.

- **Method:** GET
- **URL:** `/api/me`
- **Auth:** Bearer Token
- **Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**

```json
{
  "user": {
    "id": "671cc85341f237bf81d2a191",
    "display_name": "Farsana",
    "email": "user@example.com",
    "native_language": "ml",
    "learning_language": "en",
    "current_level": "starter",
    "level": "starter",
    "suggested_level": "starter",
    "placement_skipped": false,
    "placement_score": 6,
    "placement_total": 8,
    "age_band": "18-24",
    "learning_goals": [
      "travel",
      "work"
    ],
    "daily_goal": "regular",
    "reminder_time": "19:00",
    "reminder_days": [
      "Monday",
      "Wednesday",
      "Friday"
    ],
    "accent_color": "violet",
    "first_sticker": "first_hello",
    "onboarding_done": true
  }
}
```

---

## 10. Update Profile & Settings (Settings Screen)

Allows the user to update their settings from the app (e.g. switch level, change reminder time, update goals, change accent color).

- **Method:** PATCH
- **URL:** `/api/me`
- **Auth:** Bearer Token
- **Headers:** `Authorization: Bearer <access_token>`, `Content-Type: application/json`

**Payload (Body), send only fields to update:**

```json
{
  "display_name": "Farsana K",
  "current_level": "know_a_bit",
  "daily_goal": "intense",
  "reminder_time": "20:30",
  "reminder_days": ["Monday", "Tuesday", "Thursday", "Saturday"],
  "accent_color": "green"
}
```

**Response (200 OK):**

```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": "671cc85341f237bf81d2a191",
    "display_name": "Farsana K",
    "email": "user@example.com",
    "native_language": "ml",
    "learning_language": "en",
    "current_level": "know_a_bit",
    "level": "know_a_bit",
    "suggested_level": "starter",
    "placement_skipped": false,
    "placement_score": 6,
    "placement_total": 8,
    "age_band": "18-24",
    "learning_goals": [
      "travel",
      "work"
    ],
    "daily_goal": "intense",
    "reminder_time": "20:30",
    "reminder_days": [
      "Monday",
      "Tuesday",
      "Thursday",
      "Saturday"
    ],
    "accent_color": "green",
    "first_sticker": "first_hello",
    "onboarding_done": true
  }
}
```

---

## Reference of Allowed Values

| Field | Allowed Values |
|---|---|
| `age_band` | `"13-17"`, `"18-24"`, `"25-34"`, `"35-44"`, `"45-54"`, `"55+"` |
| `learning_goals` | Up to 3 from: `"travel"`, `"work"`, `"interview"`, `"study_abroad"`, `"move_abroad"`, `"family"`, `"exams"`, `"culture"`, `"just_learning"` |
| `daily_goal` | `"casual"`, `"regular"`, `"serious"`, `"intense"` |
| `current_level` / `suggested_level` | `"starter"`, `"know_a_bit"`, `"expert"` |
| `accent_color` | `"violet"`, `"green"`, `"orange"`, `"blue"`, `"pink"`, `"slate"` |
| `first_sticker` | `"first_hello"`, `"little_spark"`, `"well_said"`, `"explorer"`, `"star"` |
| `reminder_days` | Day names (`"Monday"`, `"Tuesday"`, etc.) or numbers (1 to 7 where 1 = Monday) |
