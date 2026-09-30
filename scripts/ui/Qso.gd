extends Screen
## 7. Goal 3: a guided first QSO. Tune in, answer the call, exchange details, spell, say 73.

const NATO := {
	"A": "Alfa", "B": "Bravo", "C": "Charlie", "D": "Delta", "E": "Echo", "F": "Foxtrot", "G": "Golf",
	"H": "Hotel", "I": "India", "J": "Juliett", "K": "Kilo", "L": "Lima", "M": "Mike", "N": "November",
	"O": "Oscar", "P": "Papa", "Q": "Quebec", "R": "Romeo", "S": "Sierra", "T": "Tango", "U": "Uniform",
	"V": "Victor", "W": "Whiskey", "X": "X-ray", "Y": "Yankee", "Z": "Zulu",
	"0": "Zero", "1": "One", "2": "Two", "3": "Three", "4": "Four", "5": "Five", "6": "Six",
	"7": "Seven", "8": "Eight", "9": "Nine",
}
const TOLERANCE := 0.006

var _stage := 0                 # 0 tune, 1 answer, 2 exchange, 3 spell, 4 sign off, 5 done
var _target := 14.2
var _freq := 14.05
var _tuned := false
var _log: Array = []            # [{"who": "them"|"me", "d": dict}]
var _order: Array = []          # shuffled choice indices for the current step
var _spell_i := 0
var _spell_opts: Array = []
var _scene: Control
var _slider: HSlider
var _t := 0.0


func _ready() -> void:
	_target = randf_range(14.10, 14.30)
	_freq = 14.02
	super._ready()


func _process(delta: float) -> void:
	_t += delta
	if _slider:
		_freq = _slider.value
		var was := _tuned
		_tuned = absf(_freq - _target) < TOLERANCE
		if _tuned and not was and _stage == 0:
			Sfx.play_morse("CQ CQ DE " + _other(), 16.0, 640.0)
			Sfx.good()
			_rebuild()
	if _scene:
		_scene.queue_redraw()


# ---- text helpers -----------------------------------------------------------------------

func _other() -> String:
	return str(Game.pack().get("partner", "W1XYZ"))


func _fmt(s: String) -> String:
	var qth := I18n.loc(Game.pack().get("partner_qth", ""))
	return s.replace("{other}", _other()).replace("{my}", Game.callsign()) \
		.replace("{name}", str(Game.profile.get("name", "")) if str(Game.profile.get("name", "")) != "" else "Alex") \
		.replace("{pname}", "Sam").replace("{pqth}", qth)


func _step_data(i: int) -> Dictionary:
	return (Content.qso.get("steps", []) as Array)[i]


# ---- layout -----------------------------------------------------------------------------

func _build() -> void:
	add_bg()
	add_header(I18n.t("qso.title"), I18n.t("qso.sub"))
	add_card(Rect2(60, 120, 540, 500))
	_scene = Control.new()
	_scene.position = Vector2(60, 120)
	_scene.size = Vector2(540, 500)
	_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene.draw.connect(_draw_radio)
	add_child(_scene)
	add_card(Rect2(640, 120, 580, 500))

	_slider = null
	if not Game.qso_ready():
		add_lbl(I18n.t("qso.need"), Vector2(672, 160), 516, 22, Palette.CREAM, Style.font_body_bold)
		add_btn(I18n.t("build.back"), Vector2(672, 400), func() -> void: SceneManager.go("hub"), "PrimaryButton", Vector2(240, 52))
		return

	_build_steps()
	if _stage == 0:
		_build_tuner()
	else:
		_build_chat()


func _build_steps() -> void:
	var labels := ["qso.step1", "qso.step2", "qso.step3", "qso.step4", "qso.step5"]
	for i in 5:
		var x := 672 + i * 104
		var dot := Panel.new()
		dot.position = Vector2(x, 146)
		dot.size = Vector2(32, 32)
		var col := Palette.LINE
		if i < _stage:
			col = Palette.GREEN
		elif i == _stage:
			col = Palette.AMBER
		dot.add_theme_stylebox_override("panel", Style.box(col, 16))
		add_child(dot)
		add_lbl(str(i + 1), Vector2(x, 150), 32, 16, Palette.INK, Style.font_display, HORIZONTAL_ALIGNMENT_CENTER)
	if _stage < 5:
		add_lbl(I18n.t(labels[_stage]), Vector2(672, 190), 516, 20, Palette.AMBER, Style.font_body_bold)


# ---- step 1: tuning ---------------------------------------------------------------------

func _build_tuner() -> void:
	add_lbl(I18n.t("qso.tune_hint"), Vector2(672, 240), 516, 20, Palette.MUTED)
	_slider = HSlider.new()
	_slider.min_value = 14.0
	_slider.max_value = 14.35
	_slider.step = 0.001
	_slider.value = _freq
	_slider.position = Vector2(100, 510)
	_slider.size = Vector2(460, 32)
	_slider.focus_mode = Control.FOCUS_NONE
	add_child(_slider)
	if _tuned:
		add_lbl(I18n.t("qso.found"), Vector2(672, 330), 516, 22, Palette.GREEN, Style.font_body_bold)
		add_btn(I18n.t("common.continue"), Vector2(672, 400), func() -> void:
			Game.set_flag("qso.tuned", true)
			Sfx.stop_morse()
			_stage = 1
			_start_step(0)
			_rebuild(), "PrimaryButton", Vector2(240, 52))


func _draw_radio() -> void:
	var ci := _scene
	Art.stars(ci, Rect2(20, 20, 500, 60), 10, _t, 5)
	if _stage == 0 and _tuned:
		Art.rings(ci, Vector2(270, 155), _t, 3, 170.0, Palette.TEAL)
	elif _stage > 0:
		Art.rings(ci, Vector2(270, 155), _t, 3, 170.0, Palette.AMBER)
	Art.gear(ci, "transceiver", Rect2(60, 60, 420, 190), 1.0 if Game.qso_ready() else 0.5, 0.0, "%.3f" % _freq)
	var d := absf(_freq - _target)
	var strength := clampf(1.0 - d / 0.05, 0.0, 1.0) if _stage == 0 else 1.0
	# signal meter
	Art.rrect(ci, Rect2(60, 290, 420, 70), Palette.INK, 16, Palette.LINE, 2)
	ci.draw_string(Style.font_body_bold, Vector2(78, 316), I18n.t("qso.signal"), HORIZONTAL_ALIGNMENT_LEFT, 200, 14, Palette.MUTED)
	for i in 12:
		var on := float(i) / 12.0 < strength
		var col := Palette.GREEN if i < 8 else Palette.CORAL
		Art.rrect(ci, Rect2(78 + i * 33, 326, 26, 20), col if on else Palette.LINE, 5)
	ci.draw_string(Style.font_mono, Vector2(60, 470), "%s  ↔  %s" % [Game.callsign(), _other() if (_stage > 0 or _tuned) else "?"], HORIZONTAL_ALIGNMENT_LEFT, 420, 22, Palette.AMBER)


# ---- steps 2..5: chat -------------------------------------------------------------------

func _start_step(step_idx: int) -> void:
	var s := _step_data(step_idx)
	_log.append({"who": "them", "d": s["them"]})
	_order = range((s["choices"] as Array).size())
	_order.shuffle()


func _build_chat() -> void:
	var start := maxi(0, _log.size() - 2)
	var y := 226.0
	for i in range(start, _log.size()):
		var e: Dictionary = _log[i]
		var mine: bool = e["who"] == "me"
		var lbl := Style.label(_fmt(I18n.loc(e["d"])), 16, Palette.INK if mine else Palette.CREAM)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size.x = 400
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", Style.box(Palette.AMBER if mine else Palette.PANEL2, 16, Palette.CLEAR, 0, Vector2(14, 10)))
		p.add_child(lbl)
		p.position = Vector2(1188.0 - 428.0 if mine else 672.0, y)
		add_child(p)
		y += p.get_combined_minimum_size().y + 10.0

	match _stage:
		1, 2, 4:
			_build_choices(_stage_step_index())
		3:
			_build_spell()
		5:
			add_title(I18n.t("qso.done"), Vector2(672, 400), 26, Palette.GREEN, 516)
			add_btn(I18n.t("build.back"), Vector2(672, 520), func() -> void:
				SceneManager.go("hub", {"goal": "qso"}), "PrimaryButton", Vector2(240, 48))
			add_btn(I18n.t("qso.replay"), Vector2(932, 520), func() -> void:
				_stage = 0
				_log.clear()
				_target = randf_range(14.10, 14.30)
				_freq = 14.02
				_tuned = false
				_rebuild(), "", Vector2(240, 48))


func _stage_step_index() -> int:
	match _stage:
		1: return 0
		2: return 1
		_: return 2


func _build_choices(step_idx: int) -> void:
	var s := _step_data(step_idx)
	add_lbl(I18n.t("qso.your_turn"), Vector2(672, 372), 516, 15, Palette.MUTED, Style.font_body_bold)
	var choices: Array = s["choices"]
	for k in _order.size():
		var idx: int = _order[k]
		var b := add_btn(_fmt(I18n.loc(choices[idx])), Vector2(672, 400 + k * 68), _on_choice.bind(step_idx, idx), "", Vector2(516, 56))
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT


func _on_choice(step_idx: int, idx: int) -> void:
	var s := _step_data(step_idx)
	if idx != int(s["c"]):
		Sfx.bad()
		toast(I18n.t("qso.wrong"), Palette.CORAL)
		return
	Sfx.good()
	_log.append({"who": "me", "d": (s["choices"] as Array)[idx]})
	match _stage:
		1:
			Game.set_flag("qso.answered", true)
			_stage = 2
			_start_step(1)
		2:
			Game.set_flag("qso.exchanged", true)
			_stage = 3
			_spell_i = 0
			_new_spell_round()
		4:
			Game.set_flag("qso.done", true)
			Sfx.reward()
			_stage = 5
	_rebuild()


# ---- spelling ---------------------------------------------------------------------------

func _new_spell_round() -> void:
	var cs := Game.callsign()
	var ch := cs[_spell_i]
	var opts: Array = [NATO[ch]]
	var pool := NATO.values()
	pool.shuffle()
	for w in pool:
		if opts.size() >= 3:
			break
		if w != NATO[ch]:
			opts.append(w)
	opts.shuffle()
	_spell_opts = opts


func _build_spell() -> void:
	var cs := Game.callsign()
	add_lbl(I18n.t("qso.step4"), Vector2(672, 372), 516, 15, Palette.MUTED, Style.font_body_bold)
	# callsign progress
	for i in cs.length():
		var col := Palette.GREEN if i < _spell_i else (Palette.AMBER if i == _spell_i else Palette.MUTED)
		add_lbl(cs[i], Vector2(672 + i * 46, 396), 40, 34, col, Style.font_mono, HORIZONTAL_ALIGNMENT_CENTER)
	for k in _spell_opts.size():
		var w: String = _spell_opts[k]
		add_btn(w, Vector2(672 + k * 176, 460), _on_spell.bind(w), "", Vector2(164, 56))


func _on_spell(word: String) -> void:
	var cs := Game.callsign()
	if word != NATO[cs[_spell_i]]:
		Sfx.bad()
		toast(I18n.t("qso.wrong"), Palette.CORAL)
		return
	Sfx.good()
	_spell_i += 1
	if _spell_i >= cs.length():
		Game.set_flag("qso.spelled", true)
		_stage = 4
		_start_step(2)
	else:
		_new_spell_round()
	_rebuild()
