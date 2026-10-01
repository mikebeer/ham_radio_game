extends Node
## Synthesised sound effects and Morse tones. No audio files needed.

const RATE := 22050
const LEAD_IN := 0.25
const MORSE := {
	"A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".", "F": "..-.", "G": "--.", "H": "....",
	"I": "..", "J": ".---", "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---", "P": ".--.",
	"Q": "--.-", "R": ".-.", "S": "...", "T": "-", "U": "..-", "V": "...-", "W": ".--", "X": "-..-",
	"Y": "-.--", "Z": "--..",
	"0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-", "5": ".....",
	"6": "-....", "7": "--...", "8": "---..", "9": "----.",
	".": ".-.-.-", ",": "--..--", "?": "..--..", "/": "-..-.",
}

var _player: AudioStreamPlayer
var _morse_player: AudioStreamPlayer
var _key_player: AudioStreamPlayer
var _cache: Dictionary = {}
var enabled := true
## Noise settings for Morse: amplitude of the static and depth of the QSB fading.
const NOISE_AMP := [0.0, 0.05, 0.13]
const QSB_DEPTH := [0.0, 0.18, 0.4]
const QSB_HZ := 0.35


func _ready() -> void:
	enabled = not Game.fact_bool("audio.sfx_off")
	_player = AudioStreamPlayer.new()
	_morse_player = AudioStreamPlayer.new()
	_key_player = AudioStreamPlayer.new()
	add_child(_player)
	add_child(_morse_player)
	add_child(_key_player)
	_key_player.stream = _loop_tone(600.0)
	_key_player.volume_db = -8.0


# ---- one-shot effects -------------------------------------------------------------------

func click() -> void:
	_play_cached("click", [[880.0, 0.04]], -14.0)


func good() -> void:
	_play_cached("good", [[523.0, 0.09], [659.0, 0.09], [784.0, 0.16]], -10.0)


func bad() -> void:
	_play_cached("bad", [[220.0, 0.16], [165.0, 0.22]], -10.0)


func reward() -> void:
	_play_cached("reward", [[392.0, 0.1], [523.0, 0.1], [659.0, 0.1], [784.0, 0.1], [1047.0, 0.35]], -9.0)


func _play_cached(name: String, notes: Array, volume_db: float) -> void:
	if not enabled:
		return
	if not _cache.has(name):
		_cache[name] = _make_sequence(notes)
	_player.stream = _cache[name]
	_player.volume_db = volume_db
	_player.play()


func _make_sequence(notes: Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	for n in notes:
		data.append_array(_tone_bytes(float(n[0]), float(n[1]), 0.5))
	return _wav(data, false)


# ---- Morse ------------------------------------------------------------------------------

func unit_seconds(wpm: float) -> float:
	return 1.2 / wpm


## Returns the sequence of [is_tone, seconds] segments for a text, in Morse timing.
## eff_wpm < wpm gives Farnsworth timing: characters are sent at `wpm`, the gaps between
## characters and words are stretched so the overall speed is `eff_wpm` (PARIS = 50 units).
func morse_segments(text: String, wpm: float, eff_wpm: float = 0.0) -> Array:
	var u := unit_seconds(wpm)
	var f := u
	if eff_wpm > 0.0 and eff_wpm < wpm:
		f = maxf(u, (60.0 / eff_wpm - 31.0 * u) / 19.0)
	var segs: Array = []
	var words := text.to_upper().split(" ", false)
	for wi in words.size():
		var word: String = words[wi]
		for ci in word.length():
			var code: String = MORSE.get(word[ci], "")
			for si in code.length():
				segs.append([true, u if code[si] == "." else 3.0 * u])
				if si < code.length() - 1:
					segs.append([false, u])
			if ci < word.length() - 1:
				segs.append([false, 3.0 * f])
		if wi < words.size() - 1:
			segs.append([false, 7.0 * f])
	return segs


func morse_duration(text: String, wpm: float, eff_wpm: float = 0.0) -> float:
	var total := 0.0
	for s in morse_segments(text, wpm, eff_wpm):
		total += float(s[1])
	return total


## noise: 0 = clean, 1 = some static and slow fading (QSB), 2 = heavy.
func play_morse(text: String, wpm: float = 12.0, freq: float = 600.0, eff_wpm: float = 0.0, noise: int = 0) -> void:
	if not enabled:
		return
	_morse_player.stream = morse_stream(text, wpm, freq, eff_wpm, noise)
	_morse_player.volume_db = -6.0
	_morse_player.play()


## The audio of a text in Morse as a stream (also used by tests).
func morse_stream(text: String, wpm: float = 12.0, freq: float = 600.0, eff_wpm: float = 0.0, noise: int = 0) -> AudioStreamWAV:
	noise = clampi(noise, 0, NOISE_AMP.size() - 1)
	var segs := morse_segments(text, wpm, eff_wpm)
	# Lead-in silence: the audio device swallows the start of a fresh stream, which made
	# "S" (...) sound like "I" (..).
	segs.push_front([false, LEAD_IN])
	segs.append([false, 0.05])
	var total := 0
	for sg in segs:
		total += int(float(sg[1]) * RATE)
	var data := PackedByteArray()
	data.resize(total * 2)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var amp: float = NOISE_AMP[noise]
	var depth: float = QSB_DEPTH[noise]
	var phase := rng.randf() * TAU
	var pos := 0
	for sg in segs:
		var n := int(float(sg[1]) * RATE)
		var tone: bool = sg[0]
		var attack := 0.006 * RATE
		var release := 0.008 * RATE
		for i in n:
			var v := 0.0
			if tone:
				var env: float = min(1.0, float(i) / attack) * min(1.0, float(n - i) / release)
				var fade := 1.0
				if depth > 0.0:
					fade = 1.0 - depth * (0.5 + 0.5 * sin(phase + TAU * QSB_HZ * float(pos + i) / RATE))
				v = sin(TAU * freq * float(i) / RATE) * 0.45 * env * fade
			if amp > 0.0:
				v += (rng.randf() * 2.0 - 1.0) * amp
			data.encode_s16((pos + i) * 2, int(clampf(v, -1.0, 1.0) * 32767.0))
		pos += n
	return _wav(data, false)


func stop_morse() -> void:
	_morse_player.stop()


func key_down() -> void:
	if enabled:
		_key_player.play()


func key_up() -> void:
	_key_player.stop()


# ---- sample generation -----------------------------------------------------------------

func _tone_bytes(freq: float, seconds: float, volume: float) -> PackedByteArray:
	var n := int(seconds * RATE)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	var attack := 0.006 * RATE
	var release := 0.008 * RATE
	for i in n:
		var env: float = min(1.0, float(i) / attack) * min(1.0, float(n - i) / release)
		var s := sin(TAU * freq * float(i) / RATE) * volume * env
		bytes.encode_s16(i * 2, int(s * 32767.0))
	return bytes


func _silence_bytes(seconds: float) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(int(seconds * RATE) * 2)
	return bytes


func _wav(data: PackedByteArray, looped: bool) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if looped:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = data.size() / 2
	return w


func _loop_tone(freq: float) -> AudioStreamWAV:
	# a whole number of cycles so the loop is click-free
	var cycles := 60
	var n := int(float(cycles) * RATE / freq)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		bytes.encode_s16(i * 2, int(sin(TAU * float(cycles) * float(i) / float(n)) * 0.4 * 32767.0))
	return _wav(bytes, true)
