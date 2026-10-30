INTEGRATION DIRECTION (applies to every API task; follow it without being reminded)

WORKING STYLE
- Lean mode: implement directly, change only what the task needs, reuse existing widgets, models and repositories. No refactors, no new packages (ask first), no extra documents.
- Write 2 to 3 focused tests in one new test file. Skip golden, responsive-size and light/dark test matrices (I check those by eye). Run flutter analyze and only the tests you touched.
- Do not invent endpoints or fields. Anything not shown in the backend's sample JSON is ASSUMED: mark it and list it as a question. Report in 10 lines at most.

STRUCTURE
- Screens and widgets never call the network. A screen reads a provider, the provider calls a repository, the repository calls the API.
- Every repository has a real and a mock implementation, with a build-time switch per feature. What the backend has not delivered stays on the mock.
- Convert server data to our own models in one place, with explicit mapping tables. Server field names never reach the screens.
- Parse tolerantly: ignore unknown fields, allow missing optional ones, never crash on an unknown value (map it to a safe default and report it).
- Parse JSON off the main thread if a response is large.

TIMING
- Every call has a timeout: connect about 10 seconds, receive about 30 seconds (longer only for endpoints known to be slow). Put the numbers in one config.
- Show a loading state immediately. After a few seconds show "still working" with a way to cancel or skip. For flows that chain several calls set a total time limit.
- Cancel in-flight calls when the user leaves the screen or changes the choice that started them. Debounce search and typing.
- Timers are only for real needs (a resend cooldown, a code expiry). They run on an injectable clock so tests can fake time, and they survive rotation and rebuilds because the state lives in a provider, not in the widget.
- Never delay a result only to show a spinner. A minimum display time is allowed only to prevent flicker, and it must be short.

RETRIES AND DUPLICATES
- Retry only safe reads, with a limit and growing waits. Never auto-retry actions that create or change things (sign-up, login, code checks, submitting answers, payments): show a Retry button instead.
- Lock the button while a call runs so a double tap cannot send twice. Add an attempt id to actions that must not repeat, if the backend supports it.
- One source of truth per piece of data: do not fetch the same thing from several places.

ERRORS, OFFLINE, EMPTY
- Handle all five states for every call: loading, success, empty, error with Retry, and offline. Every state has a short localised message and a way forward (retry, skip, go back). A server problem must never trap the user or block an optional flow.
- Map errors by HTTP status into our own failure types and show OUR translated text, never the server's. Exception: where one status code covers several different problems, use ONE clearly marked place that matches the exact documented messages, with a safe fallback when the wording changes.
- Keep what the user typed after a failure, except passwords. An expired session keeps local data and asks the user to sign in again.
- Do not trust connectivity checks: handle real failures anyway. Test slow networks and the server being off.

DATA AND CACHING
- Cache data that rarely changes: show the cached copy first, refresh in the background, and honour the server's cache headers. Offline with no cache uses a clearly marked built-in fallback, never shown as server-confirmed.
- Keep shared data and per-user data separate. Per-user data lives under the current user only. Nothing from one user may appear for another (follow the user-isolation rules in the project instructions).
- The server owns rules and results (scores, levels, streaks, unlocks). Display what it returns; do not recompute it on the phone.
- Send the user's language and options explicitly; never rely on server defaults.
- Never hardcode addresses, languages, prices or any value the server provides.

SECURITY AND PRIVACY
- Release builds use HTTPS only (plain http only in debug). Check that the Android release build has the internet permission.
- Add the login token only to calls that need it. Store it only in secure storage.
- Never log, print, store in analytics or put in error objects: passwords, codes, tokens, emails, quiz answers, correct-answer flags, personal text or full server error bodies. Network logging is off in release.
- Passwords live only in memory and are cleared when the flow ends. Never store a full birth date or year (only the age band).

USER EXPERIENCE
- Update quietly in the background without making the screen jump. Announce loading, success and errors to screen readers.
- Accessible, responsive layouts and AppPalette colours as usual (small widgets, no fixed sizes, no raw colours).

BEFORE YOU SAY IT IS DONE
- It works with the real backend on my physical phone (the server must be reachable on the PC's network address), with the server off, offline, and with a slow response.
- The release configuration is correct (HTTPS, internet permission, no debug logging or test shortcuts).
- Nothing sensitive appears in logs or stored data.
- New open questions for the backend are written down.