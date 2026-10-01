extends Node
## Spoken audio for the game: NATO words, digits and a few radio phrases.
## Uses pre-generated clips (assets/audio, made with tools/gen_audio.py) when they exist and
## falls back to the system text-to-speech. Everything plays over a "Radio" bus that gives a
## band-limited, slightly noisy sound. Clips never carry callsigns or names, those are spelled
## out letter by letter.

const DIR := "res://assets/audio/"
const MANIFEST := DIR + "manifest.json"
const PHRASES := "res://content/audio.json"
const BUS := "Radio"
const GAP := 0.28
const NATO := ["alfa", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "juliett", "kilo", "lima",
	"mike", "november", "oscar", "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey", "xray", "yankee", "zulu"]
const DIGITS := ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
const ALIASES := {"alpha": "alfa", "juliet": "juliett", "whisky": "whiskey", "x-ray": "xray", "niner": "nine"}

var enabled := true
var radio := true
var _voices: Dictionary = {}     # voice name -> {key: true}
var _phrases: Dictionary = {}    # key -> {"en": .., "de": ..}
var _say: Dictionary = {}
var _gen := 0
var _player: AudioStreamPlayer
var _noise: AudioStreamPlayer
var _cache: Dictionary = {}
var _last_voice := ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = BUS
	add_child(_player)
	_noise = AudioStreamPlayer.new()
	_noise.bus = BUS
	_noise.volume_db = -32.0
	_noise.stream = _noise_stream()
	add_child(_noise)
	_setup_bus()
	_load_manifest()
	reload()


## Reads the switches from the saved game.
func reload() -> void:
	enabled = not Game.fact_bool("audio.voice_off")
	radio = not Game.fact_bool("audio.radio_off")
	_apply_radio()


func set_enabled(on: bool) -> void:
	enabled = on
	Game.set_flag("audio.voice_off", not on)
	if not on:
		stop()


func set_radio(on: bool) -> void:
	radio = on
	Game.set_flag("audio.radio_off", not on)
	_apply_radio()


# ---- bus ------------------------------------------------------------------------------------

func _setup_bus() -> void:
	if AudioServer.get_bus_index(BUS) != -1:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, BUS)
	AudioServer.set_bus_send(idx, "Master")
	var hp := AudioEffectHighPassFilter.new()
	hp.cutoff_hz = 340.0
	var lp := AudioEffectLowPassFilter.new()
	lp.cutoff_hz = 3000.0
	AudioServer.add_bus_effect(idx, hp)
	AudioServer.add_bus_effect(idx, lp)


func _apply_radio() -> void:
	var idx := AudioServer.get_bus_index(BUS)
	if idx == -1:
		return
	for e in AudioServer.get_bus_effect_count(idx):
		AudioServer.set_bus_effect_enabled(idx, e, radio)


## One second of white noise that loops (played faintly under the voice for the radio feeling).
func _noise_stream() -> AudioStreamWAV:
	var rate := 22050
	var data := PackedByteArray()
	data.resize(rate * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in rate:
		data.encode_s16(i * 2, int((rng.randf() * 2.0 - 1.0) * 0.5 * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.data = data
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = rate
	return w


# ---- content --------------------------------------------------------------------------------

func _load_manifest() -> void:
	_voices.clear()
	if FileAccess.file_exists(MANIFEST):
		var m: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		if m is Dictionary:
			for v in (m.get("voices", {}) as Dictionary):
				var names := {}
				for k in (m["voices"][v] as Array):
					names[str(k)] = true
				_voices[str(v)] = names
	if FileAccess.file_exists(PHRASES):
		var p: Variant = JSON.parse_string(FileAccess.get_file_as_string(PHRASES))
		if p is Dictionary:
			_say = p.get("say", {})
			for e in (p.get("phrases", []) as Array):
				_phrases[str(e["key"])] = e


## Clip key for one character: "nato_delta" or "digit_one". "" for anything else.
static func key_for_char(ch: String) -> String:
	var c := ch.to_upper()
	if c.length() != 1:
		return ""
	var code := c.unicode_at(0)
	if code >= 65 and code <= 90:
		return "nato_" + NATO[code - 65]
	if code >= 48 and code <= 57:
		return "digit_" + DIGITS[code - 48]
	return ""


## Clip key for a spoken word as written in the game ("Alfa", "X-ray", "One", "Niner"). "" if unknown.
static func key_for_word(word: String) -> String:
	var w := word.to_lower().strip_edges()
	w = ALIASES.get(w, w)
	if NATO.has(w):
		return "nato_" + w
	if DIGITS.has(w):
		return "digit_" + w
	return ""


## Keys for a text spelled letter by letter (callsigns, names). Spaces and punctuation are skipped.
static func keys_for_text(text: String) -> Array:
	var out: Array = []
	for ch in text:
		var k := key_for_char(ch)
		if k != "":
			out.append(k)
	return out


static func keys_for_words(words: Array) -> Array:
	var out: Array = []
	for w in words:
		var k := key_for_word(str(w))
		if k != "":
			out.append(k)
	return out


## The file name of a clip (phrases exist in English and German).
static func clip_name(key: String, lang: String = "en") -> String:
	if key.begins_with("phrase_") and lang == "de":
		return key + "_de"
	return key


## The words for the text-to-speech fallback.
func text_for_key(key: String, lang: String = "en") -> String:
	if key.begins_with("nato_"):
		return _say.get(key.substr(5), key.substr(5).capitalize())
	if key.begins_with("digit_"):
		var d := key.substr(6)
		return "nine" if d == "nine" else d
	if key.begins_with("phrase_") and _phrases.has(key.substr(7)):
		return str((_phrases[key.substr(7)] as Dictionary).get(lang, (_phrases[key.substr(7)] as Dictionary).get("en", "")))
	return ""


# ---- availability ---------------------------------------------------------------------------

func has_clips() -> bool:
	for v in _voices:
		if (_voices[v] as Dictionary).has("nato_alfa"):
			return true
	return false


func _tts_voices(lang: String) -> PackedStringArray:
	return DisplayServer.tts_get_voices_for_language(lang)


## True when something can be heard: clips, or a system voice for the language.
func can_speak(lang: String = "en") -> bool:
	return has_clips() or not _tts_voices(lang).is_empty()


## What the Listen buttons use: can speak and the player did not switch the voice off.
func usable(lang: String = "en") -> bool:
	return enabled and can_speak(lang)


func voice_names() -> Array:
	var out: Array = []
	for v in _voices:
		if (_voices[v] as Dictionary).has("nato_alfa"):
			out.append(v)
	out.sort()
	return out


func _pick_voice(keys: Array, lang: String) -> String:
	var ok: Array = []
	for v in _voices:
		var have: Dictionary = _voices[v]
		var all := true
		for k in keys:
			if not have.has(clip_name(k, lang)):
				all = false
				break
		if all:
			ok.append(v)
	if ok.is_empty():
		return ""
	ok.sort()
	# a different voice from the last time when there is a choice
	if ok.size() > 1 and ok.has(_last_voice):
		ok.erase(_last_voice)
	_last_voice = ok[randi() % ok.size()]
	return _last_voice


func _load_clip(voice: String, name: String) -> AudioStream:
	var path := "%svoices/%s/%s.mp3" % [DIR, voice, name]
	if _cache.has(path):
		return _cache[path]
	var s: AudioStream = null
	if ResourceLoader.exists(path):
		s = load(path)
	_cache[path] = s
	return s


# ---- speaking -------------------------------------------------------------------------------

func stop() -> void:
	_gen += 1
	if _player:
		_player.stop()
	if _noise:
		_noise.stop()
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()


## Speaks the keys one after the other. Returns true when something was spoken, false when
## nothing could be heard or it was interrupted by another call (or stop()).
func speak_keys(keys: Array, lang: String = "en") -> bool:
	if not enabled or keys.is_empty():
		return false
	stop()
	var gen := _gen
	var voice := _pick_voice(keys, lang)
	if voice != "":
		return await _play_clips(voice, keys, lang, gen)
	return await _speak_tts(keys, lang, gen)


func speak_words(words: Array, lang: String = "en") -> bool:
	return await speak_keys(keys_for_words(words), lang)


func speak_text(text: String, lang: String = "en") -> bool:
	return await speak_keys(keys_for_text(text), lang)


func _play_clips(voice: String, keys: Array, lang: String, gen: int) -> bool:
	if radio:
		_noise.play()
	for k in keys:
		var s := _load_clip(voice, clip_name(k, lang))
		if s == null:
			continue
		_player.stream = s
		_player.play()
		while _player.playing and gen == _gen:
			await get_tree().process_frame
		if gen != _gen:
			return false
		await get_tree().create_timer(GAP).timeout
		if gen != _gen:
			return false
	_noise.stop()
	return true


func _speak_tts(keys: Array, lang: String, gen: int) -> bool:
	var ids := _tts_voices(lang)
	if ids.is_empty():
		return false
	var words: Array = []
	for k in keys:
		var t := text_for_key(k, lang)
		if t != "":
			words.append(t)
	if words.is_empty():
		return false
	DisplayServer.tts_speak(", ".join(words), ids[0], 80, 1.0, 0.85, 0, true)
	var waited := 0.0
	await get_tree().create_timer(0.2).timeout
	while DisplayServer.tts_is_speaking() and gen == _gen and waited < 25.0:
		await get_tree().create_timer(0.1).timeout
		waited += 0.1
	return gen == _gen
