extends Screen
## 3. Build your avatar, pick a name, country and language. Also used as the profile editor.

var _look := AvatarArt.default_look()
var _name := ""
var _country := "de"
var _name_edit: LineEdit
var _preview: ArtView
var _profile_mode := false
var _country_lbl: Label
var _rows: Dictionary = {}       # key -> {"val": Label, "sw": Panel}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_profile_mode = bool(SceneManager.params.get("profile", false))
	if _profile_mode:
		_look = Game.look()
		_name = str(Game.profile.get("name", ""))
		_country = Game.country()
	super._ready()


func _build() -> void:
	add_bg()
	var tx := 60.0
	if _profile_mode:
		add_icon("back", Vector2(40, 28), func() -> void: SceneManager.go("settings"), I18n.t("common.back"))
		tx = 116.0
	add_title(I18n.t("profile.title") if _profile_mode else I18n.t("setup.title"), Vector2(tx, 30), 44)
	add_lbl(I18n.t("profile.sub") if _profile_mode else I18n.t("setup.sub"), Vector2(tx, 92), 520, 16, Palette.MUTED)
	_build_editor()

	# right panel
	add_card(Rect2(660, 60, 560, 600))
	_preview = add_art("avatar", Rect2(720, 74, 440, 270), 0, "", _look)

	add_lbl(I18n.t("setup.name"), Vector2(700, 358), 0, 14, Palette.MUTED, Style.font_body_bold)
	_name_edit = LineEdit.new()
	_name_edit.position = Vector2(700, 382)
	_name_edit.size = Vector2(480, 52)
	_name_edit.custom_minimum_size = Vector2(480, 52)
	_name_edit.text = _name
	_name_edit.placeholder_text = I18n.t("setup.name_hint")
	_name_edit.max_length = 24
	_name_edit.text_changed.connect(func(t: String) -> void: _name = t)
	add_child(_name_edit)

	add_lbl(I18n.t("setup.country"), Vector2(700, 452), 0, 14, Palette.MUTED, Style.font_body_bold)
	var cg := ButtonGroup.new()
	var x := 700.0
	for c in Content.COUNTRIES:
		var b := _toggle(c.to_upper(), Vector2(x, 476), Vector2(80, 44), cg, c == _country)
		b.tooltip_text = I18n.t("country." + c)
		b.pressed.connect(func() -> void:
			_country = c
			_country_lbl.text = I18n.t("country." + c)
			if _profile_mode and c != Game.country():
				toast(I18n.t("profile.country_warn"), Palette.CORAL))
		x += 92.0
	_country_lbl = add_lbl(I18n.t("country." + _country), Vector2(700, 526), 480, 16, Palette.TEAL, Style.font_body_bold)

	if _profile_mode:
		_build_profile_extras()
	else:
		add_lbl(I18n.t("setup.language"), Vector2(700, 556), 0, 14, Palette.MUTED, Style.font_body_bold)
		var lg := ButtonGroup.new()
		x = 700.0
		for loc in I18n.LOCALES:
			var b := _toggle(str(loc).to_upper(), Vector2(x, 580), Vector2(62, 40), lg, loc == I18n.locale)
			b.tooltip_text = I18n.NAMES[loc]
			b.pressed.connect(func() -> void: I18n.set_locale(loc))
			x += 70.0

	var cb := add_btn(I18n.t("profile.save") if _profile_mode else I18n.t("common.continue"), Vector2(0, 592), _save if _profile_mode else _continue, "PrimaryButton", Vector2(160, 52))
	cb.position.x = 1196.0 - cb.size.x


# ---- avatar editor ----------------------------------------------------------------------

func _build_editor() -> void:
	add_card(Rect2(60, 128, 560, 492))
	_rows.clear()
	var y := 142.0
	for key in AvatarArt.ORDER:
		add_lbl(I18n.t("avatar." + key), Vector2(84, y + 6), 150, 17, Palette.CREAM, Style.font_body_bold)
		add_icon("prev", Vector2(250, y), _step.bind(key, -1), "", Vector2(44, 36))
		var sw := Panel.new()
		sw.position = Vector2(310, y + 5)
		sw.size = Vector2(26, 26)
		sw.visible = false
		add_child(sw)
		var val := add_lbl("", Vector2(346, y + 7), 140, 16, Palette.AMBER, Style.font_body_bold)
		add_icon("next", Vector2(500, y), _step.bind(key, 1), "", Vector2(44, 36))
		_rows[key] = {"val": val, "sw": sw}
		_refresh(key)
		y += 42.0
	add_btn(I18n.t("avatar.random"), Vector2(84, 566), func() -> void:
		_look = AvatarArt.random_look(_rng)
		for k in AvatarArt.ORDER:
			_refresh(k)
		_preview.look = _look
		_preview.queue_redraw(), "", Vector2(250, 40))


func _step(key: String, d: int) -> void:
	var n: int = AvatarArt.COUNTS[key]
	_look[key] = posmod(int(_look[key]) + d, n)
	_refresh(key)
	_preview.look = _look
	_preview.queue_redraw()


func _refresh(key: String) -> void:
	var v: int = _look[key]
	var n: int = AvatarArt.COUNTS[key]
	var row: Dictionary = _rows[key]
	var sw: Panel = row["sw"]
	var val: Label = row["val"]
	sw.visible = false
	val.position.x = 310.0
	match key:
		"age", "gender":
			val.text = I18n.t("avatar.%s%d" % [key, v])
		"headset":
			val.text = I18n.t("avatar.on") if v == 1 else I18n.t("avatar.off")
		"skin", "haircol", "shirt":
			var cols: Array = {"skin": AvatarArt.SKINS, "haircol": AvatarArt.HAIRS, "shirt": AvatarArt.SHIRTS}[key]
			sw.visible = true
			sw.add_theme_stylebox_override("panel", Style.box(Color(cols[v]), 13, Palette.CREAM, 2, Vector2(0, 0)))
			val.position.x = 346.0
			val.text = "%d / %d" % [v + 1, n]
		_:
			val.text = I18n.t("avatar.off") if (v == 0 and key in ["beard", "glasses", "hat"]) else "%d / %d" % [v + 1, n]


func _toggle(text: String, pos: Vector2, sz: Vector2, group: ButtonGroup, on: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.button_group = group
	b.button_pressed = on
	b.focus_mode = Control.FOCUS_NONE
	b.position = pos
	b.custom_minimum_size = sz
	b.size = sz
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_stylebox_override("normal", Style.box(Palette.PANEL2, 14, Palette.LINE, 1, Vector2(8, 6)))
	b.add_theme_stylebox_override("hover", Style.box(Palette.LINE, 14, Palette.MUTED, 1, Vector2(8, 6)))
	b.add_theme_stylebox_override("pressed", Style.box(Palette.AMBER, 14, Palette.CLEAR, 0, Vector2(8, 6)))
	b.add_theme_stylebox_override("hover_pressed", Style.box(Palette.AMBER, 14, Palette.CLEAR, 0, Vector2(8, 6)))
	b.add_theme_color_override("font_pressed_color", Palette.INK)
	b.add_theme_color_override("font_hover_pressed_color", Palette.INK)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(Sfx.click)
	add_child(b)
	return b


func _continue() -> void:
	var nm := _name.strip_edges()
	if nm == "":
		nm = "Player" if I18n.locale != "de" else "Spieler"
	Game.begin_new_game(nm, _look, _country)
	SceneManager.go("hub")


# ---- profile mode -----------------------------------------------------------------------

func _build_profile_extras() -> void:
	var has := Game.has_callsign()
	add_lbl(I18n.t("profile.callsign") + ": " + (Game.callsign() if has else I18n.t("profile.none")), Vector2(700, 566), 300, 20,
			Palette.AMBER if has else Palette.MUTED, Style.font_mono)
	if bool(FactDatabase.get_fact("rules.quiz_passed", false)):
		add_btn(I18n.t("profile.change_call"), Vector2(700, 596), func() -> void: SceneManager.go("callsign"), "", Vector2(200, 40))


func _save() -> void:
	var nm := _name.strip_edges()
	if nm == "":
		nm = str(Game.profile.get("name", "Player"))
	Game.set_profile(nm, _look)
	Game.change_country(_country)
	SceneManager.go("settings")
