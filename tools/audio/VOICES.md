# Voices for the spoken clips

Three contrasting voices, so players learn to understand different speakers and not one
recording. Create them in ElevenLabs with **Voice Design** (describe the voice in text, no real
person is cloned), then copy each voice id into `voices.json`.

| name | prompt for Voice Design |
|---|---|
| anna | A woman in her thirties, clear neutral international English, calm and friendly, medium pace, crisp consonants like an experienced radio operator. |
| tom  | A man in his fifties, warm baritone, neutral international English, measured and patient, slightly slower pace, very clear articulation. |
| kai  | A young man in his twenties, bright and energetic, neutral international English, quick but precise, clear enunciation. |

Use the sample text "Alfa Bravo Charlie, five nine, seventy three" for the preview.

## Licence and records

- Use only voices you created yourself, ElevenLabs' own default voices, or voices of people who
  agreed to this use in writing. No celebrity-like or cloned voices of third parties. Voices from
  the community Voice Library only when the listing allows commercial use.
- Generate while your subscription is active, on a plan that includes commercial use (the free
  tier does not). Check the current terms before release.
- Keep `generated.json`: it records the voice, text, model and date of every clip.
- Credit in THIRD_PARTY.md and the About text: "Voices generated with ElevenLabs".

## After generating

1. Listen to the digits (the clip for 9 says "niner"), Quebec ("keh-beck"), Juliett, Alfa and X-ray.
   Fix a bad one by changing its text under `say` in `phrases.json` and run the script again
   (only changed clips are generated).
2. Open the project in Godot once (or run `godot --headless --import`) so the clips are imported.
3. Commit `assets/audio/`, including the `.import` files, and `tools/audio/generated.json`.
