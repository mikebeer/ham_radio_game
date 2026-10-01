#!/usr/bin/env python3
"""Generate the spoken clips (NATO alphabet, digits, radio phrases) with ElevenLabs.

Run it on your own machine; it needs network access to api.elevenlabs.io and your key:

    export ELEVENLABS_API_KEY=...        # never commit the key
    python3 tools/gen_audio.py --dry-run # shows how many clips and characters (= credits)
    python3 tools/gen_audio.py           # generate whatever is missing or changed

Voices are listed in tools/audio/voices.json (create them in your ElevenLabs account first,
descriptions in tools/audio/VOICES.md, then paste the voice ids). Text lives in
tools/audio/phrases.json. Output: assets/audio/voices/<voice>/<key>.mp3 and
assets/audio/manifest.json (read by autoloads/Voice.gd). tools/audio/generated.json logs which
voice made which clip and when, keep it: it documents where every sound comes from.

Only standard library, nothing to install. Existing clips are skipped unless the text, voice
or settings changed (or you pass --force).
"""
import argparse
import datetime
import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PHRASES = os.path.join(ROOT, "tools", "audio", "phrases.json")
VOICES = os.path.join(ROOT, "tools", "audio", "voices.json")
LOG = os.path.join(ROOT, "tools", "audio", "generated.json")
OUT = os.path.join(ROOT, "assets", "audio")

MODEL = "eleven_multilingual_v2"
FORMAT = "mp3_44100_128"
SETTINGS = {"stability": 0.6, "similarity_boost": 0.75, "style": 0.0, "use_speaker_boost": True}

# Keep these two lists identical to autoloads/Voice.gd.
NATO = ["alfa", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "juliett", "kilo", "lima",
        "mike", "november", "oscar", "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey",
        "xray", "yankee", "zulu"]
DIGITS = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]


def jobs(data, groups, langs):
    """Yields (key, text) for every clip. The key is also the file name."""
    say = data.get("say", {})
    if "nato" in groups:
        for w in NATO:
            yield "nato_" + w, say.get(w, w.capitalize())
    if "digits" in groups:
        for d in DIGITS:
            yield "digit_" + d, say.get(d, d)
    if "phrases" in groups:
        for p in data["phrases"]:
            for lang in langs:
                if lang in p:
                    yield "phrase_%s%s" % (p["key"], "" if lang == "en" else "_" + lang), p[lang]


def fingerprint(text, voice_id):
    raw = json.dumps([text, voice_id, MODEL, SETTINGS], sort_keys=True)
    return hashlib.sha1(raw.encode()).hexdigest()[:12]


def synth(text, voice_id, key):
    base = os.environ.get("ELEVENLABS_API_BASE", "https://api.elevenlabs.io")  # override only for tests
    url = "%s/v1/text-to-speech/%s?output_format=%s" % (base, voice_id, FORMAT)
    body = json.dumps({"text": text, "model_id": MODEL, "voice_settings": SETTINGS}).encode()
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "xi-api-key": key, "Content-Type": "application/json", "Accept": "audio/mpeg"})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            detail = e.read().decode(errors="replace")[:300]
            if e.code == 429 and attempt < 3:
                time.sleep(5 * (attempt + 1))
                continue
            if e.code in (401, 403):
                sys.exit("ElevenLabs refused the key or the voice (%d): %s" % (e.code, detail))
            sys.exit("ElevenLabs error %d: %s" % (e.code, detail))
        except urllib.error.URLError as e:
            if attempt < 3:
                time.sleep(3)
                continue
            sys.exit("Cannot reach api.elevenlabs.io: %s" % e.reason)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true", help="only count clips and characters")
    ap.add_argument("--voice", action="append", help="only this voice name (repeatable)")
    ap.add_argument("--only", action="append", choices=["nato", "digits", "phrases"], help="only this group")
    ap.add_argument("--lang", action="append", choices=["en", "de"], help="phrase languages (default en and de)")
    ap.add_argument("--force", action="store_true", help="regenerate even when nothing changed")
    ap.add_argument("--pause", type=float, default=0.3, help="seconds between requests")
    args = ap.parse_args()

    data = json.load(open(PHRASES, encoding="utf-8"))
    voices = json.load(open(VOICES, encoding="utf-8"))["voices"]
    voices = [v for v in voices if not args.voice or v["name"] in args.voice]
    groups = args.only or ["nato", "digits", "phrases"]
    langs = args.lang or ["en", "de"]
    log = json.load(open(LOG, encoding="utf-8")) if os.path.exists(LOG) else {}
    api_key = os.environ.get("ELEVENLABS_API_KEY", "")
    todo = []
    for v in voices:
        if v["voice_id"].startswith("PASTE"):
            print("skipping %s: no voice id in tools/audio/voices.json yet" % v["name"])
            continue
        for key, text in jobs(data, groups, langs):
            path = os.path.join(OUT, "voices", v["name"], key + ".mp3")
            fp = fingerprint(text, v["voice_id"])
            entry = log.get("%s/%s" % (v["name"], key))
            if args.force or not os.path.exists(path) or not entry or entry.get("hash") != fp:
                todo.append((v, key, text, path, fp))
    chars = sum(len(t[2]) for t in todo)
    print("%d clips to generate, %d characters (about that many credits)" % (len(todo), chars))
    if args.dry_run:
        return
    if not todo:
        write_manifest()
        return
    if not api_key:
        sys.exit("Set ELEVENLABS_API_KEY first (export ELEVENLABS_API_KEY=...).")
    for n, (v, key, text, path, fp) in enumerate(todo, 1):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        audio = synth(text, v["voice_id"], api_key)
        with open(path, "wb") as f:
            f.write(audio)
        log["%s/%s" % (v["name"], key)] = {
            "text": text, "voice_id": v["voice_id"], "model": MODEL, "hash": fp, "chars": len(text),
            "generated": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}
        print("[%d/%d] %s/%s  %r" % (n, len(todo), v["name"], key, text))
        with open(LOG, "w", encoding="utf-8") as f:
            json.dump(log, f, ensure_ascii=False, indent=1, sort_keys=True)
        time.sleep(args.pause)
    write_manifest()
    print("Done. Listen to a few clips (especially digits and Quebec/Juliett), then open the project in "
          "Godot once so the clips are imported, and commit assets/audio and tools/audio/generated.json.")


def write_manifest():
    """assets/audio/manifest.json: which clips exist for which voice."""
    manifest = {"voices": {}}
    root = os.path.join(OUT, "voices")
    if os.path.isdir(root):
        for name in sorted(os.listdir(root)):
            clips = sorted(f[:-4] for f in os.listdir(os.path.join(root, name)) if f.endswith(".mp3"))
            if clips:
                manifest["voices"][name] = clips
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1)
    names = ", ".join("%s (%d clips)" % (k, len(v)) for k, v in manifest["voices"].items())
    print("manifest: " + (names or "no voices yet"))


if __name__ == "__main__":
    main()
