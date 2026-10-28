# &#x20;                                      ***TUTOTOCO***

##### &#x20;Auth APIs Base URL: http://127.0.0.1:8000





##### **1. Placement Test APIs**



* ###### **API 1 — Get Intro Message**

GET /api/placement/intro?



Pebbi's welcome message — auto-translated to user's native language.



###### Success Response — 200:



json

{

&#x20; "pebbi\_says": "Hola, friend! 👋 Let's see how much you know. No pressure — just have fun! 😎",

&#x20; "subtitle": "8 quick ones · About 2 minutes · Ends in a win"

}

If user's native language is Malayalam → returns in Malayalam automatically



* ###### **API 2 — Get Questions**

GET /api/placement/questions

GET /api/placement/questions?target\_language=es\&native\_language=ml





Returns 8 questions in user's native language. Languages come from user's onboarding choices — no params needed.



###### Success Response — 200 (test available):



json

{

&#x20; "available": true,

&#x20; "total": 8,

&#x20; "questions": \[

&#x20;   {

&#x20;     "id": "6710abc001",

&#x20;     "sort\_order": 1,

&#x20;     "difficulty": "A1",

&#x20;     "question\_text": "Here you are! 🎁",

&#x20;     "target\_phrase": "Aquí tiene",

&#x20;     "options": \[

&#x20;       {"emoji": "🤝", "label": "Here you are!", "is\_correct": true},

&#x20;       {"emoji": "👋", "label": "Goodbye!",       "is\_correct": false},

&#x20;       {"emoji": "🙅", "label": "No way!",        "is\_correct": false},

&#x20;       {"emoji": "🤷", "label": "I don't know",   "is\_correct": false}

&#x20;     ],

&#x20;     "fun\_fact": "You'll hear this every day in Spain!",

&#x20;     "pebbi\_correct": "¡Muy bien! 🔥 You're off to a flying start!",

&#x20;     "pebbi\_wrong": "Oopsie! 'Aquí tiene' is what waiters say when they serve you! 🍽️",

&#x20;     "pebbi\_warning": null

&#x20;   },

&#x20;   {

&#x20;     "id": "6710abc002",

&#x20;     "sort\_order": 6,

&#x20;     "difficulty": "B1",

&#x20;     "question\_text": "I've been waiting an hour! ⏰",

&#x20;     "target\_phrase": "Llevo una hora esperando",

&#x20;     "options": \[...],

&#x20;     "pebbi\_warning": "Heads up — this one's trickier! You've got this 💪"

&#x20;   }

&#x20; ]

}

###### Response when test not available for language — 200:



json

{

&#x20; "available": false,

&#x20; "message": "Coming soon! Starting at Starter level 🌱",

&#x20; "default\_level": "starter"

}

###### How frontend should use this:



**Field	           Use**

target\_phrase	Speak via TTS when user taps "Hear it" button

pebbi\_warning	Show Pebbi warning BEFORE displaying the question (only on hard ones — null on easy)

pebbi\_correct	Show when user picks correct emoji

pebbi\_wrong	Show when user picks wrong emoji

fun\_fact	Show after answer (correct or wrong)

is\_correct	Hidden from display — use only to check answer locally



* ###### **API 3 — Submit Answers**

POST /api/placement/submit



Send all 8 answers after quiz ends. Backend scores and assigns level.



###### Request Body:



json

{

&#x20; "native\_language": "ml",

&#x20; "answers": \[

&#x20;   {"question\_id": "6710abc001", "chosen\_emoji": "🤝"},

&#x20;   {"question\_id": "6710abc002", "chosen\_emoji": "🧾"},

&#x20;   {"question\_id": "6710abc003", "chosen\_emoji": "🗺️"},

&#x20;   {"question\_id": "6710abc004", "chosen\_emoji": "😡"},

&#x20;   {"question\_id": "6710abc005", "chosen\_emoji": "🪑"},

&#x20;   {"question\_id": "6710abc006", "chosen\_emoji": "⏳"},

&#x20;   {"question\_id": "6710abc007", "chosen\_emoji": "😬"},

&#x20;   {"question\_id": "6710abc008", "chosen\_emoji": "🔮"}

&#x20; ]

}

###### Success Response — 200:



json

{

&#x20; "score": 6,

&#x20; "total": 8,

&#x20; "score\_pct": 75,

&#x20; "level": "expert",

&#x20; "identity": "Star 🌟",

&#x20; "emoji": "🌟",

&#x20; "message": "You're a Star! Let's go! 🌟",

&#x20; "estimated\_note": "Estimated starting point based on this short quiz"

}



###### All possible result levels:



**score\_pct  	level		identity**

75–100%		expert		Star 🌟

50–74%		know\_a\_bit	Explorer ⚡

25–49%		starter		Speedster 🚀

0–24%		starter		Newbie 🌱

ℹ️ After this call, user's level is saved. Next call to GET /api/tracks will return lessons for their level automatically.



###### Full Flow for Frontend:

1\. GET /api/placement/intro        → Show Pebbi intro screen

2\. GET /api/placement/questions    → Load all 8 questions

3\. User taps "Hear it"             → Frontend TTS speaks target\_phrase

4\. User picks emoji                → Show pebbi\_correct or pebbi\_wrong + fun\_fact

5\. After Q8 → POST /api/placement/submit  → Show result screen with identity + level

6\. Tap "Start my adventure" 	   → go to home/tracks screen



\########################################################################################



##### **2. Register**

POST /api/auth/register



###### Request Body:



json

{

&#x20; "email": "farsana@example.com",

&#x20; "password": "Secret123!",

&#x20; "display\_name": "Farsana",



&#x20; "native\_language": "ml",

&#x20; "learning\_language": "es",

&#x20; "current\_level": "starter",

&#x20; "age\_band": "25-34",

&#x20; "learning\_goals": \["travel", "just\_learning"],

&#x20; "daily\_goal": "regular",

&#x20; "reminder\_time": "19:00",

&#x20; "reminder\_days": \["M", "T", "W", "T", "F", "S", "S"],

&#x20; "accent\_color": "#7C3AED",

&#x20; "first\_sticker": "first\_hello"

}



###### Success Response — 200:



{

&#x20; "message": "Verification code sent to farsana@example.com",

&#x20; "expires\_in": "10 minutes"

}

Error Response — 400:



json

{

&#x20; "detail": "Email already registered"

}



###### All possible errors — 400:



json

{"detail": "Invalid email address"}

{"detail": "Password must have: at least 8 characters"}

{"detail": "Password must have: at least 1 uppercase letter"}

{"detail": "Password must have: at least 1 number"}

{"detail": "Display name cannot be empty"}

{"detail": "Email already registered. Please log in."}



**⚠️ Only email, password, display\_name are required. All other fields are optional — frontend can send only what's available.**



###### Full Frontend Flow — Step by Step



**Phase 1 — Onboarding Screens (No API calls!)**

Screen 2: User picks age → store locally: age\_band = "25-34"

Screen 3: User picks language → store locally: native\_language = "ml"

Screen 4: User picks learning → store locally: learning\_language = "es"

Screen 5: User picks goals → store locally: learning\_goals = \["travel"]

Screen 7: User picks goal → store locally: daily\_goal = "regular"

Screen 8: User picks reminder → store locally: reminder\_time = "19:00", reminder\_days = \[...]

Screen 9: User picks color → store locally: accent\_color = "#7C3AED", first\_sticker = "first\_hello"

All stored in app memory / AsyncStorage (no API yet!)



**Phase 2 — Placement Test (2 API calls, no token)**

Step 1: GET /api/placement/questions?target\_language=es\&native\_language=ml

&#x20;       → loads all 8 questions

Step 2: User answers all 8 questions (frontend handles locally)

Step 3: POST /api/placement/submit

&#x20;       Body: { "native\_language": "ml", "answers": \[...] }

&#x20;

&#x20;       Response: { "level": "starter", "identity": "Newbie 🌱", ... }

&#x20;

&#x20;       → store locally: current\_level = "starter"



**Phase 3 — Register Screen (2 API calls, no token)**

User enters: email + password + display\_name

Step 1: POST /api/auth/register

&#x20;       Body: {

&#x20;         "email": "...",

&#x20;         "password": "...",

&#x20;         "display\_name": "Farsana",

&#x20;

&#x20;         ← everything from Phase 1 (local storage):

&#x20;         "native\_language": "ml",

&#x20;         "learning\_language": "es",

&#x20;         "age\_band": "25-34",

&#x20;         "learning\_goals": \["travel"],

&#x20;         "daily\_goal": "regular",

&#x20;         "reminder\_time": "19:00",

&#x20;         "reminder\_days": \[...],

&#x20;         "accent\_color": "#7C3AED",

&#x20;         "first\_sticker": "first\_hello",

&#x20;

&#x20;         ← from Phase 2 (placement test result):

&#x20;         "current\_level": "starter"

&#x20;       }

&#x20;       Response: { "message": "Verification code sent..." }

Step 2: User enters OTP from email

Step 3: POST /api/auth/verify-otp

&#x20;       Body: { "email": "...", "otp": "847291" }

&#x20;       Response: { "access\_token": "...", "user": {...} }

&#x20;

&#x20;       → Save token! User is now logged in ✅



###### Summary Table

**Phase	      Screen	API Call	         Stores**

Onboarding	2–9	❌ None                 Local memory

Placement	6	✅ GET questions	Local memory

Placement	6	✅ POST submit	        current\_level locally

Register	10	✅ POST register	Triggers OTP email

Verify OTP	11	✅ POST verify-otp	Token + all data to DB

Total: 4 API calls for full signup! 🚀

\########################################################################################



##### **3. verify otp**

POST /api/auth/verify-otp

###### Request:



json

{

&#x20; "email": "farsana@example.com",

&#x20; "otp": "847291"

}

###### Success — 200:



json

{

&#x20; {

&#x20; "access\_token": "eyJhbGciOiJIUzI1NiIs...",

&#x20; "token\_type": "bearer",

&#x20; "user": {

&#x20;   "id": "6710abc123",

&#x20;   "display\_name": "Farsana",

&#x20;   "email": "farsana@example.com",

&#x20;   "level": "starter",

&#x20;   "learning\_language": "es",

&#x20;   "native\_language": "ml",

&#x20;   "accent\_color": "#7C3AED",

&#x20;   "onboarding\_done": true

&#x20; }

}

&#x20; }

}

Errors — 400:



json

{"detail": "Invalid OTP. Please check and try again."}

{"detail": "OTP expired. Please request a new one."}

{"detail": "OTP already used. Please request a new one."}



###### Frontend Flow:

Onboarding screens (stored locally in app)

&#x20;        ↓

Placement test → POST /api/placement/submit → save level locally

&#x20;        ↓

"Create Account" screen

&#x20; - Enter name, email, password

&#x20; - Tap "Send Code"

&#x20;        ↓

POST /api/auth/send-otp  (send level + languages from local storage)

&#x20;        ↓

"Enter Code" screen

&#x20; - Enter 6-digit code from email

&#x20; - Tap "Verify"

&#x20;        ↓

POST /api/auth/verify-otp

&#x20;        ↓

✅ Save token → Go to Home screen



\########################################################################################



##### **4. Login**

POST /api/auth/login



###### Request Body:



json

{

&#x20; "email": "user@example.com",

&#x20; "password": "yourpassword"

}

###### Success Response — 200:



json

{

&#x20; "access\_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",

&#x20; "token\_type": "bearer",

&#x20; "user": {

&#x20;   "id": "6710abc123...",

&#x20;   "display\_name": "Farsana",

&#x20;   "email": "user@example.com",

&#x20;   "language\_pref": "es"

&#x20; }

}

Error Response — 401:



json

{

&#x20; "detail": "Invalid email or password"

}

How to use the token (for all future APIs)

After login/register, save the access\_token. Send it in every API request header like this:



Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...



\########################################################################################



##### **5. 📖 Lessons (User-facing)**



* ###### **GET /api/lessons/track/{track\_id}**

Get all lessons in a track with user's progress and lock status.



###### Request:





GET /api/lessons/track/daily

Authorization: Bearer <token>



###### Response:



json



{

&#x20; "track\_id": "daily",

&#x20; "lessons": \[

&#x20;   {

&#x20;     "lesson\_id": "daily-starter-1",

&#x20;     "lesson\_number": 1,

&#x20;     "level": "starter",

&#x20;     "level\_order": 1,

&#x20;     "title": "Say Hello",

&#x20;     "icon": "👋",

&#x20;     "xp\_reward": 10,

&#x20;     "status": "not\_started",

&#x20;     "locked": false

&#x20;   },

&#x20;   {

&#x20;     "lesson\_id": "daily-starter-2",

&#x20;     "lesson\_number": 2,

&#x20;     "level": "starter",

&#x20;     "level\_order": 2,

&#x20;     "title": "At the Café",

&#x20;     "icon": "☕",

&#x20;     "xp\_reward": 10,

&#x20;     "status": "not\_started",

&#x20;     "locked": true

&#x20;   }

&#x20; ]

}

locked: true = user must complete previous lesson first

status: not\_started / in\_progress / complete



* ###### **GET /api/lessons/{lesson\_id}?native\_language=ml\&learning\_language=ar**

Get full lesson content with phrases auto-translated to learning language, meanings in native language.



###### Request:





GET /api/lessons/daily-starter-1?native\_language=ml\&learning\_language=ar

Authorization: Bearer <token>

native\_language: user's mother tongue (default: en)

learning\_language: language user is learning (default: en = English)

Both default to en — no translation needed if not provided



###### Response:



json



{

&#x20; "lesson\_id": "daily-starter-1",

&#x20; "track": "daily",

&#x20; "level": "starter",

&#x20; "lesson\_number": 1,

&#x20; "level\_order": 1,

&#x20; "title": "Say Hello",

&#x20; "goal": "Greet someone and tell them your name",

&#x20; "pebbi\_intro": "Let's learn how to say hello!",

&#x20; "dialogue\_prompt": "Hi! What's your name?",

&#x20; "dialogue\_correct": "My name is Sam.",

&#x20; "icon": "👋",

&#x20; "xp\_reward": 10,

&#x20; "total\_phrases": 6,

&#x20; "phrases": \[

&#x20;   {

&#x20;     "position": 1,

&#x20;     "phrase\_id": "ph\_good\_morning",

&#x20;     "target\_text": "صباح الخير",

&#x20;     "translation": "സുപ്രഭാതം",

&#x20;     "tags": \["greeting"],

&#x20;     "image\_emoji": "🌅",

&#x20;     "distractors": \["مساء الخير", "وداعاً", "أراك لاحقاً"]

&#x20;   }

&#x20; ],

&#x20; "assessment\_config": {

&#x20;   "total\_questions": 6,

&#x20;   "pass\_score": 4,

&#x20;   "include\_speak\_attempt": false

&#x20; },

&#x20; "questions": \[

&#x20;   {

&#x20;     "question\_id": "abc123",

&#x20;     "question\_type": "pick\_meaning",

&#x20;     "phrase\_id": "ph\_good\_morning",

&#x20;     "answer\_choices": \["Good morning", "Good night", "Goodbye", "See you"],

&#x20;     "hint": "Think about the morning!",

&#x20;     "points": 1,

&#x20;     "order": 1

&#x20;   }

&#x20; ],

&#x20; "user\_progress": {

&#x20;   "status": "not\_started",

&#x20;   "score": null,

&#x20;   "xp\_earned": 0,

&#x20;   "attempts": 0

&#x20; }

}

correct\_answer\_ref is NEVER included in questions

native\_language: user's mother tongue — controls translation field (meaning in their language)

learning\_language: language being learned — controls target\_text + distractors

Both auto-translate on first request and cache in DB for future users



###### Language combinations example:





native\_language=ml \& learning\_language=ar

&#x20; → target\_text: Arabic phrase (صباح الخير)

&#x20; → translation: Malayalam meaning (സുപ്രഭാതം)

&#x20; → distractors: Arabic wrong options

native\_language=hi \& learning\_language=fr

&#x20; → target\_text: French phrase (Bonjour)

&#x20; → translation: Hindi meaning (सुप्रभात)

&#x20; → distractors: French wrong options

native\_language=en \& learning\_language=en (default)

&#x20; → target\_text: English phrase (Good morning)

&#x20; → translation: English (no translation)

&#x20; → distractors: English wrong options

* ###### **POST /api/lessons/{lesson\_id}/check — Check ONE answer (per-question feedback)**

Call this after user answers each question. Server returns correct answer ONLY after user has submitted.



###### Request:



json



{

&#x20; "question\_id": "abc123",

&#x20; "chosen\_answer": "Good morning"

}

###### Response:



json



{

&#x20; "question\_id": "abc123",

&#x20; "is\_correct": true,

&#x20; "correct\_answer": "Good morning",

&#x20; "chosen\_answer": "Good morning",

&#x20; "points\_earned": 1

}

✅ correct\_answer is revealed HERE — only after user has already answered

Frontend shows green ✅ or red ❌ + highlights correct answer

Frontend stores points\_earned locally to track score



* ###### **POST /api/lessons/{lesson\_id}/submit**

Submit ALL answers after finishing all questions. Server calculates final score and awards XP.



###### Request:



json



{

&#x20; "answers": \[

&#x20;   { "question\_id": "abc123", "chosen\_answer": "Good morning" },

&#x20;   { "question\_id": "abc124", "chosen\_answer": "Goodbye" },

&#x20;   { "question\_id": "abc125", "chosen\_answer": "Thank you" },

&#x20;   { "question\_id": "abc126", "chosen\_answer": "Please" },

&#x20;   { "question\_id": "abc127", "chosen\_answer": "Sorry" },

&#x20;   { "question\_id": "abc128", "chosen\_answer": "Yes" }

&#x20; ]

}

###### Response:



json



{

&#x20; "passed": true,

&#x20; "score": 5,

&#x20; "total": 6,

&#x20; "score\_pct": 83,

&#x20; "xp\_awarded": 10,

&#x20; "next\_lesson\_id": "daily-starter-2",

&#x20; "pebbi\_says": "¡Perfecto! 🎉 You scored 5/6! Keep going!"

}

xp\_awarded is only > 0 on FIRST completion

next\_lesson\_id is null if no next lesson or lesson not passed

pebbi\_says varies based on score

**⚠️ Always call /submit at the end even if you called /check per question — /check does NOT save progress**



* ###### **GET /api/lessons/{lesson\_id}/progress**

Get user's progress for a specific lesson.



###### Response:



json



{

&#x20; "status": "complete",

&#x20; "score": 5,

&#x20; "xp\_earned": 10,

&#x20; "attempts": 2,

&#x20; "completed\_at": "2024-10-20T10:30:00Z",

&#x20; "next\_lesson\_id": "daily-starter-2"

}

###### **🎮 Complete Lesson Flow (Duolingo-style)**



1\. GET /api/lessons/track/daily

&#x20;  → Show lesson map (locked/unlocked)

2\. User taps a lesson →

&#x20;  GET /api/lessons/daily-starter-1?native\_language=ml

&#x20;  → Show 6 phrases (with translations)

&#x20;  → Store questions locally (NO correct answers yet)

3\. User studies phrases → taps "Start Quiz"

4\. For EACH question (repeat 6 times):

&#x20;  → Show question + 4 answer choices

&#x20;  → User picks an answer

&#x20;  → POST /api/lessons/daily-starter-1/check

&#x20;    { question\_id: "abc123", chosen\_answer: "Good morning" }

&#x20;  → Response: { is\_correct: true, correct\_answer: "Good morning", points\_earned: 1 }

&#x20;  → Show ✅ green (correct) or ❌ red + highlight correct answer

&#x20;  → Wait 1.5s → next question

5\. After all 6 answered →

&#x20;  POST /api/lessons/daily-starter-1/submit

&#x20;  { answers: \[ {question\_id, chosen\_answer} × 6 ] }

&#x20;  → Response: { passed: true, score: 5, xp\_awarded: 10, next\_lesson\_id: "daily-starter-2" }

&#x20;  → Show results screen: XP earned, Pebbi reaction, Next button

6\. User taps Next →

&#x20;  GET /api/lessons/track/daily

&#x20;  → Lesson 2 is now unlocked



###### **⚠️ Important Rules for Frontend**

**Rule					Detail**

Never send correct\_answer\_ref		Backend never returns this

Lesson locking				Check locked: true before allowing access

XP awarded once				Only first completion gives XP

Native language				Always pass ?native\_language=ml (or user's lang)

Pass score				Show assessment\_config.pass\_score / total\_questions to user before starting

Speak attempt				If include\_speak\_attempt: true, show speaking task separately (unscored)

📝 Workflow Summary

