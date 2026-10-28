# Backend Integration Questions & Clarifications

This document tracks technical questions, edge cases, and design alignments between the Flutter mobile client team and the backend API team.

---

## Active Questions

### 1. `/api/placement/intro` Query Parameters
- **Context:** The draft document mentions `GET /api/placement/intro`, but does not specify query parameters.
- **Question:** Does `/api/placement/intro` require `native_language` and `target_language` query parameters (similar to `/api/placement/questions?native=ml&target=en`), or is it static content? Currently, the mobile client holds the DTO and fixture with `native_language` and `target_language` fields, but does not invoke this endpoint on screen since intro text is statically localized.

### 2. Server Enforcement of `age_band` and COPPA Compliance
- **Context:** The mobile app evaluates the user's birth year into one of the six allowed age bands (`13-17`, `18-24`, `25-34`, `35-44`, `45-54`, `55+`). If the learner's youngest possible age is under 13, the client-side age gate blocks progression and discards the draft.
- **Question:** Does the server endpoint `POST /api/auth/register` enforce an age-band check or reject requests missing a valid band? Does the backend maintain COPPA compliance rules, or does it rely entirely on client-side gating?

### 3. Quiz Utterance Accent and Voice Localization
- **Context:** On the placement quiz ("Quick Check"), the user can tap "Hear it" to listen to the target English phrase.
- **Question:** Which English accent/voice should be targeted for the launch course (e.g., General American `en-US`, British `en-GB`, Indian English `en-IN`)? The client currently defaults to `en-US`. Will audio URLs eventually be provided in the question payload, or should TTS remain the primary audio driver?

### 4. Placement Questions Caching & Dynamic Refresh
- **Context:** Placement questions are currently fetched on entry to Step 6.
- **Question:** How frequently are question sets rotated per language pair? Can questions be cached locally for offline retries within the same onboarding session, or should each attempt request a fresh set?

### 5. Registration Idempotency and Resubmission Safety
- **Context:** Mobile users may encounter network flickers while submitting registration payloads.
- **Question:** Does `POST /api/auth/register` support an `Idempotency-Key` or `X-Request-ID` header to prevent duplicate user creation on retry?

### 6. Rate Limit (`429 Too Many Requests`) Headers
- **Context:** The app's `RetryInterceptor` inspects `429` responses.
- **Question:** Does the API return a standard `Retry-After` header in seconds (integer) or an HTTP-date format?

### 7. Standardization of Error Payload Schemas
- **Context:** Mobile error mapping strips raw server text to prevent echoing sensitive input (passwords, emails).
- **Question:** Can we guarantee that all 4xx/5xx responses return `{ "detail": ... }` where detail is either a string or a list of validation errors (`loc`, `msg`, `type`), and never include unescaped raw user input?

### 8. Session Token Refresh Strategy
- **Context:** `TokenStorage` stores `active_user_id` and auth tokens in secure storage (Keystore/Keychain).
- **Question:** What is the token lifetime for access tokens and refresh tokens? Will refresh tokens be rotated on each call to `/api/auth/refresh`?
