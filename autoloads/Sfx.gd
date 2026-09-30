extends Node
## Synthesised sound effects and Morse tones. No audio files needed.

const RATE := 22050
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


func _ready() -> void:
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
func morse_segments(text: String, wpm: float) -> Array:
	var u := unit_seconds(wpm)
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
				segs.append([false, 3.0 * u])
		if wi < words.size() - 1:
			segs.append([false, 7.0 * u])
	return segs


func morse_duration(text: String, wpm: float) -> float:
	var total := 0.0
	for s in morse_segments(text, wpm):
		total += float(s[1])
	return total


func play_morse(text: String, wpm: float = 12.0, freq: float = 600.0) -> void:
	if not enabled:
		return
	var data := PackedByteArray()
	for s in morse_segments(text, wpm):
		if s[0]:
			data.append_array(_tone_bytes(freq, float(s[1]), 0.45))
		else:
			data.append_array(_silence_bytes(float(s[1])))
	data.append_array(_silence_bytes(0.05))
	_morse_player.stream = _wav(data, false)
	_morse_player.volume_db = -6.0
	_morse_player.play()


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
