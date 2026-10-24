# DESIGN_SPEC.md — Pebbi visual reference

Companion to `AGENTS.md`. Source: screenshots of the Base44 prototype (phone width only), saved in `design/`.

**Status of values:** colours, sizes, and fonts below were read **by eye from screenshots**. They are marked *(estimated)* and are provisional. Exact values must come from the prototype's `index.css` / Tailwind config. When they arrive, update `core/theme` only; widget code must not change. There are **no tablet/iPad designs**: follow Section 4 of `AGENTS.md`.

Screens covered here: Home (Path), Missions, Review (Phrases tab), Rewards, Settings (top part), Welcome cards (3). All other screens are still to be supplied.

---

## 1. Look and feel

Friendly, rounded, playful, "no pressure". Large rounded cards on a soft lavender background, chunky 3D buttons with a visible bottom edge, one mascot (Pebbi) on almost every screen. Generous whitespace, short copy, emoji/icons inside soft tinted tiles.

## 2. Colour tokens

| Token | Value | Use |
|---|---|---|
| `brandPurple` | `#6C4DF6` (confirmed) | Primary buttons, selected chips, unit header, active tab icon, links |
| `brandPurpleDepth` | ~`#4B33C4` *(estimated)* | Bottom edge of purple 3D buttons |
| `mint` | ~`#2DD4A4` *(estimated)* | Success/start: play button, "Get started", goal ring, toggle on |
| `mintDepth` | ~`#1CA67E` *(estimated)* | Bottom edge of green 3D buttons |
| `coral` | ~`#FF7A5A` *(estimated)* | Missions: Today's mission card, difficulty pips, streak flame tint |
| `coralDepth` | ~`#D9532F` *(estimated)* | Bottom edge of the coral card |
| `background` | ~`#F5F4FB` *(estimated)* | App background (soft lavender-grey) |
| `surface` | `#FFFFFF` | Cards, pills, inactive chips |
| `tintLavender` | ~`#EDE9FF` *(estimated)* | Icon tiles, selected-chip fill, segmented control track |
| `tintMint`, `tintSky`, `tintPeach`, `tintRose` | very light tints *(estimated)* | Welcome-card backgrounds, mission icon tiles, warning tile |
| `textPrimary` | ~`#1E1647` dark navy-purple *(estimated)* | Titles, body strong |
| `textMuted` | ~`#6E6A8A` *(estimated)* | Subtitles, captions |
| `locked/disabled` | light lavender-grey | Locked nodes, empty calendar cells |
| `accent` | user-selectable (chosen at "Meet Pebbi") | Tints the mascot and accent UI. Define a palette of options. Default is violet |

Dark theme: not shown in screenshots. Derive it from the tokens and flag it as an assumption.

## 3. Typography

- **Headings:** rounded, chunky display face (looks like a Baloo-style font) *(estimated, confirm)*. Used for screen titles, card titles, button labels.
- **Body:** soft rounded sans (looks like Nunito) *(estimated, confirm)*.
- Scale: large screen titles (~24 to 28), card titles (~18 to 20), body (~14 to 16), captions and small labels (~11 to 13), uppercase small caps for card overlines ("CONTINUE", "TODAY'S MISSION", "UNIT · 0 OF 3 STOPS DONE").
- Must support text scale up to 200%, plus Japanese, Arabic (RTL), and Malayalam (explanation language) with proper fallback fonts.
- Confirm exact font names and licences before bundling.

## 4. Shape, elevation, spacing

- Cards: white, large radius (~20 to 24), soft shadow *(estimated)*.
- Buttons and pills: fully or highly rounded (~16 to 20 on buttons, full pill on chips and top pills).
- Icon tiles: rounded square (~14 to 16) with tinted fill.
- Screen horizontal padding ~16; vertical gaps between cards ~12 to 16 *(estimated)*.
- Minimum tap target 48dp. Use spacing tokens, never inline numbers. Clamp any scaling so tablets do not get oversized controls (`AGENTS.md` Section 4).

## 5. Core components

**Button3D** (already built): solid colour face plus a darker bottom edge; the face moves down onto the edge when pressed; disabled state is flat and muted. Variants seen: purple (primary, e.g. "Next", "Share the invite", "Practise tricky phrases", "+"), mint ("Get started", play button), coral (Today's mission card is a large 3D card). Full width or compact/icon-only. Sits at the bottom of onboarding cards.

**TopPills** (Home): app logo tile with sparkle; language pill ("Ñ Español" with chevron); streak pill (flame + count); stars pill (star + count); round profile button. White pills with soft shadow.

**TrackChips**: horizontally laid chips (e.g. "Everyday talk", "Travel") with a small icon. Selected: lavender fill with purple outline and purple text. Unselected: white with light outline.

**Filter chips** (Missions, Review): small pills (All, Everyday, Travel, Health, Money, Social...; All, Tricky, New, Saved). Selected: solid purple (Review) or purple outline (Missions). The Missions row scrolls horizontally; **do not show a scrollbar** (the prototype's visible scrollbar is a web artifact).

**ContinueCard**: lavender icon tile with mascot, overline "CONTINUE", title ("Say hello"), caption ("About 3 min · tap to start"), round mint 3D play button on the right.

**DueStrip**: white rounded bar, sparkle icon, one line of text ("Nothing due — your phrases are strong"), purple "Review" link on the right.

**AdBanner** (free users): white card with tinted icon, "AD" tag, ad title, "Sponsored" caption, and a grey pill button "Remove ads · Premium $3.99/month". The price must come from the store/config, not hardcoded.

**UnitHeader**: full-width purple card, overline "UNIT · 0 OF 3 STOPS DONE", title "First conversations", book icon button on the right, thin progress bar at the bottom.

**PathNode**: large circle (purple with a white star for the current node; locked/done variants), 3D edge, label beneath ("Say hello"), mascot sitting beside the current node, thin connector line to the next node, winding left/right placement. Other node types: Review, Mission, Chest.

**MissionHeroCard**: large coral 3D card, overline "TODAY'S MISSION", cup icon tile, title ("Order a coffee"), caption ("Lucía, barista · about 5 min").

**Quick action cards** (two side by side): "Emergency phrasebook" (rose tile, warning icon) and "Free talk" (lavender tile, chat icon). White cards, bold title.

**MissionListTile**: peach icon tile, title, caption ("Lucía, barista · 5 min"), difficulty pips (3 small segments, coral when filled), tag pill on the right ("new").

**Segmented tabs** (Review: Phrases / Practice / Library): pill track in lavender, selected segment white with shadow.

**InviteCard**: lavender icon tile, "Invite a friend", caption, link field with "Copy", full-width purple 3D "Share the invite" button.

**EmptyState**: centered mascot (winking), bold title ("No phrases yet"), one-line explanation.

**Rewards**: header (mascot with yellow level badge, title "Your progress", subtitle "Spanish · level 1 · Pebbi's little scarf", gear button); three stat tiles (stops done, phrases, stars); **GoalRing** card (mint ring with check, "Daily goal: 1 lesson", status text, purple reminder text, level progress bar "Level 1 ... Level 2 at 40 stars"); **StreakCard** (flame icon, "1 day streak", "1 active days · 2 freezes ready", "calendar" pill); **StreakCalendar** "Last 4 weeks" (7-column grid of rounded cells with day numbers, today is the last cell with a flame, empty cells in light lavender-grey).

**Settings**: back link "Back to the path"; mascot plus name text field ("Your first name"); section cards with emoji headers ("Courses", "Goal and reminders"); choice chips (languages shown in their own script: Español, Français, Deutsch, 日本語, العربية; level: Little, Know a bit, Expert); labelled rows with small icon, title, helper text, and a control (dropdown, e.g. "Explanations in" with Malayalam; mint toggle for "Show helper line"); goal options as wide chips ("Casual · 5 min a day", "Regular · 10 min a day"...).

**Bottom navigation (5 tabs):** Path, Missions, Review, Rewards, Settings. Icon over label; active tab has a lavender pill behind the icon and purple colour. On medium/expanded windows this becomes a navigation rail.

**Welcome cards** (3 pages): "Skip" top right; big rounded tinted card (lavender, mint, sky) holding the mascot, bold centered title, grey subtitle, and 2 to 3 white info chips; pill-shaped page indicator (active dot is wider); full-width 3D "Next" button; last page uses the mint "Get started" button with small caption "Free to start. No card, no countdown."

## 6. Mascot (Pebbi)

Round bear-like character: round ears with pink inner ear, white face, simple eyes, pink cheeks, smile. Appears in teal/green and purple, so the **body colour follows the accent colour**. Has **outfits** unlocked by level (seen: scarf, backpack, cape/other). Expressions seen: happy, winking. Appears at small size in cards, medium on headers, large in onboarding.

**Do not redraw it approximately.** Ask for the source artwork (SVG, Rive, or Lottie) with accent colour variants, outfits, and expressions. Until then use a clearly marked placeholder.

## 7. Behaviour details read from the screens

- Home shows a hint under the chips: "Little mode · tap your profile to change it". "Little" is the level name (Little, Know a bit, Expert).
- Level progress: level 2 at 40 stars.
- Premium price shown in the ad card: $3.99/month (show the store price in the app).
- Streak card mentions **freezes** ("2 freezes ready"): freezes are a real UI concept.
- Review shows the **invite card** on the Phrases tab.
- Missions list has difficulty (pips), duration (minutes), and a "new" tag; filter chips include categories such as Everyday, Travel, Health, Money, Social.
- Explanation language list includes Indian languages (Malayalam seen): needs correct fonts and shaping.

## 8. Prototype issues: do NOT copy

1. Rewards shows "Daily goal: Done today — nicely done!" and "1 day streak" while stops done = 0. The prototype counts finishing onboarding as an active day. Active days must come from real learning activity (confirm with the client).
2. Wrong plural: "1 active days". Use proper pluralisation (ICU plural messages).
3. Home says "Nothing due — your phrases are strong" even when the user has no phrases yet. Use a distinct "start your first lesson" message.
4. Visible desktop-style scrollbars on chip rows. Hide them.
5. Layout was only designed for a phone width. Do not stretch it on tablets.
6. Hardcoded copy and prices: use localisation strings and store data.

## 9. Screens still needed

Splash, the 11 onboarding setup steps, placement check, "course ready", auth screens (login, register, reset), lesson intro, each exercise type, feedback panel, redo round, finish screen, test-out, locked-node sheet, chest, profile/stats/streak/language sheets, mission brief, role-play chat, debrief, Review → Practice and Library tabs, flashcards, add-phrase sheet, sticker book, badges, premium screens, emergency phrasebook, rest of Settings, dark mode, and any tablet designs.