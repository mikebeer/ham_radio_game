# CQ Quest - open issues

Status 2026-10-01. P1 = before any public release, P2 = soon, P3 = nice to have.

## Content accuracy and review

| # | Pri | Issue |
|---|-----|-------|
| 1 | P1 | German lessons are condensed from 50ohm by an AI; a native radio amateur should read all DE cards (shack parts x 3 levels, DE rules x 3 levels). |
| 2 | P1 | English lessons are an unofficial translation of the German source; needs review. |
| 3 | P1 | Italian, French, Spanish and Latin UI strings are AI translations, unreviewed (flagged "AI" in the language picker). A few short labels are abbreviated (IT `Ricetrasm.`, `Misur. SWR`; FR `Émetteur-récept.`) and may read clipped. |
| 4 | P1 | Library: facts written from memory, not from 50ohm, need checking: FT8/FT4/PSK31/SSTV/APRS frequencies, 145.500 and 144.300 calling frequencies, repeater offsets (600 kHz on 2 m, 7.6 MHz on 70 cm), +/-2.5 kHz FM deviation, SOTA (4 contacts) and POTA (10 contacts) rules, IARU founding year (1925), HAREC/T-R 61-02 wording, D-STAR and DMR numbers, Yagi gain "about 5 dB", German class power limits (N 10 W, E 100 W, A 750 W PEP), 4 km x sqrt(height) radio horizon rule. |
| 5 | P1 | Shack decks not based on 50ohm text (general knowledge, still to be verified): Morse key (dit/dah timing, PARIS, 1.2/WPM, key clicks, QSK, keyers), logbook (ADIF syntax, UTC-5 example), microphone (modulation index), SWR (reflection coefficient and return-loss formulas), dynamic range of receivers. |
| 6 | P2 | Diode threshold: 50ohm says Ge 0.2-0.3 V and Si 0.6-0.7 V, the official quiz answer says 0.2-0.4 V and 0.6-0.8 V. The card follows 50ohm and has a tip. |
| 7 | P2 | Power limits (class E/A) in the DE cards come from the question catalogue, not the 50ohm text (which only shows Annex 1 as a photo). |
| 8 | P2 | Question pools: the old shack-part quiz questions were written earlier and not checked against the catalogue; some answers are only "partly supported" by 50ohm (SWR 1.5 acceptable, FT8 clock accuracy, microphone bias, 4 and 8 ohm speakers, "no daylight saving" for UTC). |
| 9 | P2 | Class N card "Country prefixes, ITU regions, DX" lists prefixes taken from the 50ohm prefix tables; check them. |
| 10 | P2 | Photo 1079 (one of the used drawings) has no reviewed alt text in 50ohm. |

## Countries and levels

| # | Pri | Issue |
|---|-----|-------|
| 11 | P1 | AT, CH, US, UK rules lessons are short original primers, not exam material. The owner has more websites to use; then build card decks like DE (and for AT Klasse 3, 4, 1 with the class facts supplied). |
| 12 | P1 | Austria: the 2009 BMVIT question catalogue has no stated licence; only topics and abbreviations are used. Clearance or a replacement source is needed. The Klasse 3/4/1 questions are my own primers. |
| 13 | P2 | Austria: shack tiers for Klasse 4 and 1 are generic except antenna and QSO scripts (adapted to bands). The state map (callsign digits 1-9) is not drawn yet. |
| 14 | P2 | Switzerland has one level only (HB3); HB9 levels missing. US and UK have 3 levels but only primer depth. |
| 15 | P2 | Callsign choice only on level 1; a new callsign per class on level-up (DE: N to E to A) is not implemented. |
| 16 | P3 | Italy, France, Spain as countries (own rules chapters) - the languages exist, the legal packs do not. |

## Features still planned

| # | Pri | Issue |
|---|-----|-------|
| 17 | P2 | Callsign prefix game with a Europe map (Natural Earth borders, simplified polygons drawn in code). |
| 18 | P2 | UTC and time-zone calculations game. |
| 19 | P2 | Lesson decks for Morse (Koch method, speed), QSO (procedure, Q-codes) and the callsign mini-game. |
| 20 | P2 | Library: entries exist in EN and DE only (other languages show English); no deep links from lesson cards to library terms yet; level gating not used. |
| 21 | P3 | Lessons and questions in Italian, French, Spanish (Latin UI only). |
| 22 | P3 | More badges, daily streak, sound/music, haptics. |

## Product, legal and release

| # | Pri | Issue |
|---|-----|-------|
| 23 | P1 | Trademark check for "CQ Quest" (DPMA, EUIPO, USPTO, app stores). Domain cq-quest.com is reserved, no site or web export yet. |
| 24 | P1 | Attribution review: 50ohm (CC BY 4.0) text and 52 drawings/photos, Bundesnetzagentur catalogue (DL-DE-BY-2.0), fonts (OFL), Godot (MIT). Credit line is in the lesson card, About and THIRD_PARTY.md. |
| 25 | P2 | Google Play availability of "Ham Gaming" and "Ham Learning" was not confirmed; market review is Apple App Store only. |
| 26 | P2 | Privacy statement needed (no tracking, local save file only; sharing only opens the OS/browser). |
| 27 | P2 | Figma file still has only the first 8 screens. Missing: avatar editor, settings (6 tabs), badges, statistics, library, lesson cards, share dialog, callsign finder, level-up, language picker. |

## Technical

| # | Pri | Issue |
|---|-----|-------|
| 28 | P1 | Not tested on real devices: touch layout, small phones, Android/iOS/web exports. Web share (`navigator.share` via JavaScriptBridge) untested. |
| 29 | P1 | Morse: an earlier report of a possible dit/dah confusion was withdrawn by the owner (the table was verified), cause of the doubt unconfirmed. Re-test audio on real devices; 0.25 s lead-in silence was added as a precaution. |
| 30 | P2 | No CI. Tests run by hand: `tests/levels.gd`, `tests/flow.gd`, `tools/smoke.gd`. A GitHub Action with headless Godot would help. |
| 31 | P2 | Headless runs print leaked-RID warnings at exit (harmless, from test scripts quitting early). |
| 32 | P2 | Accessibility: no font scaling, no colour-blind check, no screen-reader labels; scrolling lesson text is touch-draggable but not keyboard-navigable. |
| 33 | P3 | Save file has no version number; migrations (e.g. study flags) are done ad hoc in `Game.load_game()`. |
| 34 | P3 | Quest task names in `ham.cfg` are English only (not shown in the UI today). |
| 35 | P3 | Avatar: no child avatars on purpose; headwear list is short (cap, beanie, headscarf); more skin/hair/accessory options possible. |
| 37 | P2 | Spelling trainer (NATO alphabet only): digits are accepted as numerals, English and German number words; code words are spoken only when clips or a system voice exist (see 38); umlauts are folded to the base letter (Ü to U) for names and places; the QSO goal does not link to it yet and it is not a quest task (only a badge). |
| 38 | P1 | Spoken audio: the clips are not generated yet (needs the ElevenLabs voices and a run of `tools/gen_audio.py` on the owner's machine). Until then the system text-to-speech is used: quality and voices differ per device, and it is silent on Linux without speech-dispatcher and for Latin. Check by ear: digits ("niner"), Quebec, Juliett, Alfa, X-ray. |
| 39 | P1 | ElevenLabs licence: confirm the plan allows commercial use and shipping the generated audio in a distributed game; use only own designed voices (see `tools/audio/VOICES.md`); add the credit line to the About text once clips ship. |
| 40 | P2 | Audio on real devices untested: web needs a first tap before sound plays (the hub provides it), iOS silent switch can mute game audio (audio session category), Android latency for fast Morse. |
| 41 | P2 | Audio is only wired into the spelling trainer and Morse. Not yet: spoken QSO partner lines (the 20 phrase clips are generated but unused), a "copy the callsign" Morse task (Farnsworth spacing exists in `Sfx` but has no screen), listening tasks in the quiz. |
