extends Screen
## 8. Goal 4: Morse by the Koch method. Listen and pick, or send it yourself.

const SEQ := "KMRSUAPTLOWI.NJEF0Y,VG5/Q9ZH38B?4271CD6X"
const ROUNDS := 10
const NEED := 8
const CELL := Vector2(62, 56)

var _level := 1
var _mode := "listen"           # listen, send, result
var _round := 0
var _hits := 0
var _target := ""
var _options: Array = []
var _locked := false
var _picked := ""
var _passed := false
var _grid: Control
var _t := 0.0
var _play_start := -1.0
var _segs: Array = []
# send mode
var _keydown_at := -1.0
var _pattern := ""
var _last_up := -1.0
var _sent_msg := ""


func _ready() -> void:
	_level = clampi(Game.morse_passed() + 1, 1, Game.morse_cap())
	_new_round()
	super._ready()
	# play the first character after the screen is up
	get_tree().create_timer(0.5).timeout.connect(_play)


func _exit_tree() -> void:
	Sfx.stop_morse()


func _wpm() -> float:
	return float(clampi(Game.fact_int("morse.wpm", 12), 5, 30))


func _known_count() -> int:
	return mini(SEQ.length(), 4 + 4 * (_level - 1))


func _known() -> String:
	return SEQ.substr(0, _known_count())


func _newest() -> String:
	return SEQ.substr(maxi(0, _known_count() - 4), 4)


# ---- rounds -----------------------------------------------------------------------------

func _new_round() -> void:
	_locked = false
	_picked = ""
	var pool := _known()
	# favour the newest characters
	var src := _newest() if randf() < 0.5 else pool
	_target = src[randi() % src.length()]
	var opts: Array = [_target]
	var guard := 0
	while opts.size() < 4 and guard < 100:
		guard += 1
		var c := pool[randi() % pool.length()]
		if not opts.has(c):
			opts.append(c)
	opts.shuffle()
	_options = opts
	_pattern = ""
	_sent_msg = ""


func _play() -> void:
	if not is_inside_tree() or _mode != "listen" or _target == "":
		return
	Sfx.play_morse(_target, _wpm())
	_segs = [[false, Sfx.LEAD_IN]] + Sfx.morse_segments(_target, _wpm())
	_play_start = _t


func _on_pick(c: String) -> void:
	if _locked:
		return
	_locked = true
	_picked = c
	if c == _target:
		_hits += 1
		Sfx.good()
	else:
		Sfx.bad()
	_rebuild()
	get_tree().create_timer(0.9).timeout.connect(_after_pick)


func _after_pick() -> void:
	if not is_inside_tree() or _mode != "listen":
		return
	_round += 1
	if _round >= ROUNDS:
		_passed = _hits >= NEED
		if _passed:
			Game.set_flag("morse.passed", maxi(Game.morse_passed(), _level))
			Sfx.reward()
		_mode = "result"
	else:
		_new_round()
	_rebuild()
	if _mode == "listen":
		_play()


func _restart_level() -> void:
	_round = 0
	_hits = 0
	_mode = "listen"
	_new_round()
	_rebuild()
	_play()


# ---- layout -----------------------------------------------------------------------------

func _build() -> void:
	add_bg()
	add_header(I18n.t("morse.title"), I18n.t("morse.sub", [_level, Game.morse_cap()]))
	add_card(Rect2(60, 120, 540, 500))
	add_lbl(I18n.t("morse.known"), Vector2(92, 140), 0, 14, Palette.MUTED, Style.font_body_bold)
	_grid = Control.new()
	_grid.position = Vector2(60, 120)
	_grid.size = Vector2(540, 500)
	_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grid.draw.connect(_draw_grid)
	add_child(_grid)
	_build_speed()
	add_card(Rect2(640, 120, 580, 500))

	if _mode != "result":
		add_btn(I18n.t("morse.play"), Vector2(672, 140), _switch.bind("listen"),
				"PrimaryButton" if _mode == "listen" else "", Vector2(180, 44))
		add_btn(I18n.t("morse.send"), Vector2(870, 140), _switch.bind("send"),
				"PrimaryButton" if _mode == "send" else "", Vector2(200, 44))
	match _mode:
		"listen":
			_build_listen()
		"send":
			_build_send()
		"result":
			_build_result()


func _build_speed() -> void:
	var lbl := add_lbl(I18n.t("morse.speed", [int(_wpm())]), Vector2(92, 556), 300, 16, Palette.CREAM, Style.font_body_bold)
	var sl := HSlider.new()
	sl.min_value = 5
	sl.max_value = 30
	sl.step = 1
	sl.value = _wpm()
	sl.position = Vector2(300, 556)
	sl.size = Vector2(270, 28)
	sl.focus_mode = Control.FOCUS_NONE
	sl.value_changed.connect(func(v: float) -> void: lbl.text = I18n.t("morse.speed", [int(v)]))
	sl.drag_ended.connect(func(changed: bool) -> void:
		if changed:
			Game.set_flag("morse.wpm", int(sl.value))
			if _mode == "listen":
				_play())
	add_child(sl)


func _switch(m: String) -> void:
	if m == _mode:
		if m == "listen":
			_play()
		return
	Sfx.stop_morse()
	_mode = m
	_new_round()
	_rebuild()
	if m == "listen":
		_play()


func _build_listen() -> void:
	add_lbl(I18n.t("morse.round", [_round + 1, ROUNDS]), Vector2(672, 210), 0, 15, Palette.MUTED, Style.font_body_bold)
	add_lbl(I18n.t("morse.listen"), Vector2(672, 236), 516, 22, Palette.AMBER, Style.font_display)
	for k in _options.size():
		var c: String = _options[k]
		var b := add_btn(c, Vector2(672 + (k % 2) * 264, 300 + (k / 2) * 110), _on_pick.bind(c), "", Vector2(244, 92))
		b.add_theme_font_override("font", Style.font_mono)
		b.add_theme_font_size_override("font_size", 44)
		if _locked:
			b.disabled = true
			if c == _target:
				b.add_theme_color_override("font_disabled_color", Palette.GREEN)
			elif c == _picked:
				b.add_theme_color_override("font_disabled_color", Palette.CORAL)
	add_lbl("%d / %d" % [_hits, _round], Vector2(1100, 210), 88, 20, Palette.GREEN, Style.font_display, HORIZONTAL_ALIGNMENT_RIGHT)


func _build_result() -> void:
	var col := Palette.GREEN if _passed else Palette.CORAL
	add_title(I18n.t("common.score", [_hits, ROUNDS]), Vector2(672, 150), 40, col, 516)
	if _passed:
		add_lbl(I18n.t("morse.levelup") if Game.morse_passed() < Game.morse_cap() else I18n.t("build.all_done"), Vector2(672, 230), 516, 22, Palette.CREAM, Style.font_body_bold)
		if _level < Game.morse_cap():
			add_btn(I18n.t("common.next"), Vector2(672, 400), func() -> void:
				_level += 1
				_restart_level(), "PrimaryButton", Vector2(200, 52))
			add_btn(I18n.t("build.back"), Vector2(892, 400), func() -> void: SceneManager.go("hub"), "", Vector2(240, 52))
		else:
			add_btn(I18n.t("build.back"), Vector2(672, 400), func() -> void:
				SceneManager.go("hub", {"goal": "morse"}), "PrimaryButton", Vector2(280, 52))
	else:
		add_lbl(I18n.t("morse.levelfail", [NEED, ROUNDS]), Vector2(672, 230), 516, 22, Palette.CREAM, Style.font_body_bold)
		add_btn(I18n.t("common.retry"), Vector2(672, 400), _restart_level, "PrimaryButton", Vector2(200, 52))
		add_btn(I18n.t("build.back"), Vector2(892, 400), func() -> void: SceneManager.go("hub"), "", Vector2(240, 52))


# ---- send mode --------------------------------------------------------------------------

func _build_send() -> void:
	add_lbl(I18n.t("morse.practice_send"), Vector2(672, 210), 0, 15, Palette.MUTED, Style.font_body_bold)
	add_lbl(_target, Vector2(672, 236), 120, 64, Palette.AMBER, Style.font_mono)
	add_lbl(_code_of(_target), Vector2(800, 262), 380, 40, Palette.TEAL, Style.font_mono)
	add_lbl(I18n.t("morse.you_sent") + ": " + _pattern + ("   " + _sent_msg if _sent_msg != "" else ""), Vector2(672, 340), 516, 22, Palette.CREAM, Style.font_mono)
	var key := Button.new()
	key.text = I18n.t("morse.hold")
	key.position = Vector2(672, 420)
	key.custom_minimum_size = Vector2(516, 96)
	key.focus_mode = Control.FOCUS_NONE
	key.theme_type_variation = "PrimaryButton"
	key.button_down.connect(_key_down)
	key.button_up.connect(_key_up)
	add_child(key)
	add_btn(I18n.t("morse.clear"), Vector2(672, 540), func() -> void:
		_pattern = ""
		_sent_msg = ""
		_rebuild(), "", Vector2(160, 44))


func _code_of(c: String) -> String:
	return str(Sfx.MORSE.get(c, "")).replace(".", "· ").replace("-", "– ").strip_edges()


func _input(e: InputEvent) -> void:
	if _mode != "send":
		return
	if e is InputEventKey and e.keycode == KEY_SPACE and not e.echo:
		if e.pressed:
			_key_down()
		else:
			_key_up()
		get_viewport().set_input_as_handled()


func _key_down() -> void:
	if _keydown_at >= 0.0:
		return
	_keydown_at = _t
	Sfx.key_down()


func _key_up() -> void:
	if _keydown_at < 0.0:
		return
	Sfx.key_up()
	var held := _t - _keydown_at
	_keydown_at = -1.0
	_pattern += "." if held < 2.0 * Sfx.unit_seconds(_wpm() - 4.0) else "-"
	_last_up = _t
	if _mode == "send":
		_rebuild()


func _check_send() -> void:
	var code: String = Sfx.MORSE.get(_target, "")
	if _pattern == code:
		Sfx.good()
		_sent_msg = "✓"
		_rebuild()
		get_tree().create_timer(0.8).timeout.connect(func() -> void:
			if is_inside_tree() and _mode == "send":
				_new_round()
				_rebuild())
	elif _pattern.length() >= code.length():
		Sfx.bad()
		_sent_msg = "✗"
		_pattern = ""
		_rebuild()


# ---- drawing ----------------------------------------------------------------------------

func _process(delta: float) -> void:
	_t += delta
	if _mode == "send" and _keydown_at < 0.0 and _last_up >= 0.0:
		_last_up = -1.0
		_check_send()
	if _grid:
		_grid.queue_redraw()


func _lamp_on() -> bool:
	if _mode == "send":
		return _keydown_at >= 0.0
	if _play_start < 0.0:
		return false
	var el := _t - _play_start
	for s in _segs:
		var d: float = s[1]
		if el < d:
			return s[0]
		el -= d
	return false


func _draw_grid() -> void:
	var ci := _grid
	var known := _known_count()
	var newest_from := maxi(0, known - 4)
	for i in SEQ.length():
		var col := i % 8
		var row := i / 8
		var r := Rect2(Vector2(22 + col * CELL.x, 56 + row * CELL.y), CELL - Vector2(6, 6))
		var c := SEQ[i]
		if i >= known:
			Art.rrect(ci, r, Palette.fade_ink(0.35), 10, Palette.LINE, 1)
			continue
		var isnew := i >= newest_from
		Art.rrect(ci, r, Palette.AMBER if isnew else Palette.PANEL2, 10)
		var fg := Palette.INK if isnew else Palette.CREAM
		ci.draw_string(Style.font_mono, r.position + Vector2(0, 26), c, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 22, fg)
		var code: String = Sfx.MORSE.get(c, "")
		var w := 0.0
		for ch in code:
			w += 5.0 if ch == "." else 13.0
		w += (code.length() - 1) * 5.0
		var x := r.position.x + (r.size.x - w) / 2.0
		for ch in code:
			var ln := 5.0 if ch == "." else 13.0
			ci.draw_rect(Rect2(x, r.position.y + 40, ln, 4), fg)
			x += ln + 5.0
	# lamp
	var on := _lamp_on()
	var lamp := Vector2(270, 384)
	if on:
		ci.draw_circle(lamp, 40, Art.fade(Palette.AMBER, 0.25))
	ci.draw_circle(lamp, 30, Palette.AMBER if on else Palette.LINE)
	ci.draw_arc(lamp, 30, 0.0, TAU, 32, Palette.AMBER_DEEP, 3.0, true)
