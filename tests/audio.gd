extends SceneTree
## Audio logic: godot --headless --path . --script tests/audio.gd

func _check(ok: bool, msg: String) -> void:
	if not ok:
		print("FAIL: ", msg)
		quit(1)


func _initialize() -> void:
	for i in 5:
		await process_frame
	var g = root.get_node("Game")
	var sfx = root.get_node("Sfx")
	var voice = root.get_node("Voice")
	g.begin_new_game("Test", 1, "de")

	# --- Morse timing: standard and Farnsworth
	var plain: float = sfx.morse_duration("PARIS PARIS PARIS", 20.0)
	# 3 words = 3*50 units, but no gap after the last word: 143 units of 0.06 s
	_check(absf(plain - 143.0 * 0.06) < 0.001, "standard timing %f" % plain)
	_check(absf(sfx.morse_duration("PARIS PARIS PARIS", 20.0, 25.0) - plain) < 0.001, "eff >= wpm changes nothing")
	var f := (60.0 / 10.0 - 31.0 * 0.06) / 19.0
	var farns: float = sfx.morse_duration("PARIS PARIS PARIS", 20.0, 10.0)
	_check(absf(farns - (18.0 - 7.0 * f)) < 0.001, "Farnsworth keeps 10 WPM overall: %f" % farns)
	var segs: Array = sfx.morse_segments("EE", 20.0, 10.0)
	_check(absf(float(segs[1][1]) - 3.0 * f) < 0.001, "letter gap stretched")
	_check(absf(float(sfx.morse_segments("E T", 20.0, 10.0)[1][1]) - 7.0 * f) < 0.001, "word gap stretched")
	_check(absf(float(sfx.morse_segments("A", 20.0, 10.0)[1][1]) - 0.06) < 0.001, "gap inside a letter unchanged")

	# --- Morse audio: noise only when asked
	var clean: AudioStreamWAV = sfx.morse_stream("E", 20.0, 600.0, 0.0, 0)
	var noisy: AudioStreamWAV = sfx.morse_stream("E", 20.0, 600.0, 0.0, 2)
	_check(clean.data.size() == noisy.data.size() and clean.data.size() > 1000, "same length")
	var quiet := true
	var hiss := false
	for i in range(0, 2000, 2):    # inside the lead-in silence
		if clean.data.decode_s16(i) != 0:
			quiet = false
		if noisy.data.decode_s16(i) != 0:
			hiss = true
	_check(quiet and hiss, "clean silence is silent, noisy silence hisses")

	# --- keys
	_check(voice.key_for_char("D") == "nato_delta" and voice.key_for_char("7") == "digit_seven", "char keys")
	_check(voice.key_for_char("-") == "" and voice.key_for_char("AB") == "", "no key for other characters")
	_check(voice.key_for_word("Niner") == "digit_nine" and voice.key_for_word("Nine") == "digit_nine", "niner")
	_check(voice.key_for_word("X-ray") == "nato_xray" and voice.key_for_word("Alpha") == "nato_alfa", "aliases")
	_check(voice.key_for_word("Juliet") == "nato_juliett" and voice.key_for_word("Whisky") == "nato_whiskey", "aliases 2")
	_check(voice.key_for_word("Charly") == "", "unknown word")
	_check(voice.keys_for_text("DL1 ab").size() == 5, "keys for a callsign-like text")
	_check(voice.clip_name("phrase_cq", "de") == "phrase_cq_de" and voice.clip_name("nato_alfa", "de") == "nato_alfa", "clip names")
	var spell = load("res://scripts/ui/Spell.gd")
	_check(spell.LETTERS.size() == 26 and voice.NATO.size() == 26, "26 letters")
	for ch in spell.LETTERS:
		_check(voice.key_for_word(spell.LETTERS[ch]) == voice.key_for_char(ch), "Spell word %s maps to its clip key" % ch)
	for d in 10:
		_check(voice.key_for_word(spell.DIGIT_WORDS[str(d)][0]) == voice.key_for_char(str(d)), "digit word %d" % d)
	# the generation script uses the same word lists
	var py := FileAccess.get_file_as_string("res://tools/gen_audio.py")
	for w in voice.NATO:
		_check(py.contains('"%s"' % w), "gen_audio.py lists " + w)
	for w in voice.DIGITS:
		_check(py.contains('"%s"' % w), "gen_audio.py lists " + w)

	# --- text for the text-to-speech fallback
	_check(voice.text_for_key("nato_quebec") == "Keh-beck" and voice.text_for_key("nato_alfa") == "Alfa", "say overrides")
	_check(voice.text_for_key("digit_nine") == "nine" and voice.text_for_key("digit_two") == "two", "digits")
	_check(voice.text_for_key("phrase_over", "de") == "kommen" and voice.text_for_key("phrase_over") == "over", "phrases")
	_check(voice.text_for_key("phrase_nope") == "", "unknown phrase")

	# --- voices: only a voice that has every clip is chosen
	voice._voices = {"a": {"nato_alfa": true, "nato_bravo": true}, "b": {"nato_alfa": true}}
	_check(voice._pick_voice(["nato_alfa"], "en") in ["a", "b"], "either voice")
	_check(voice._pick_voice(["nato_alfa", "nato_bravo"], "en") == "a", "only a has both")
	_check(voice._pick_voice(["nato_zulu"], "en") == "", "no voice has it")
	_check(voice.voice_names() == ["a", "b"], "voice names")
	voice._voices = {}
	_check(not voice.has_clips(), "no clips")

	# --- bus and switches
	var bus: int = AudioServer.get_bus_index("Radio")
	_check(bus != -1 and AudioServer.get_bus_effect_count(bus) == 2, "radio bus with two filters")
	voice.set_radio(false)
	_check(not AudioServer.is_bus_effect_enabled(bus, 0) and g.fact_bool("audio.radio_off"), "radio off")
	voice.set_radio(true)
	_check(AudioServer.is_bus_effect_enabled(bus, 0) and AudioServer.is_bus_effect_enabled(bus, 1), "radio on")
	voice.set_enabled(false)
	_check(g.fact_bool("audio.voice_off") and not voice.usable(), "voice off is saved")
	_check(not await voice.speak_keys(["nato_alfa"]), "nothing is spoken when switched off")
	voice.set_enabled(true)
	_check(not g.fact_bool("audio.voice_off"), "voice on")
	_check(not await voice.speak_keys([]), "nothing to say")
	print("AUDIO OK")
	quit()
