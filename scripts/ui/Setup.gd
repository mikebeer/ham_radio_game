extends Screen
## 3. Choose avatar, name, country and language.

var _avatar := 1
var _name := ""
var _country := "de"
var _name_edit: LineEdit
var _preview: ArtView


func _build() -> void:
	add_bg()
	add_title(I18n.t("setup.title"), Vector2(60, 36), 48)
	add_lbl(I18n.t("setup.sub"), Vector2(60, 108), 560, 18, Palette.MUTED)

	var group := ButtonGroup.new()
	for i in Game.AVATAR_COUNT:
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = (i == _avatar)
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(60 + (i % 3) * 190, 170 + (i / 3) * 210)
		b.custom_minimum_size = Vector2(170, 190)
		b.size = Vector2(170, 190)
		b.add_theme_stylebox_override("normal", Style.box(Palette.PANEL, 24, Palette.LINE, 1))
		b.add_theme_stylebox_override("hover", Style.box(Palette.PANEL2, 24, Palette.MUTED, 1))
		b.add_theme_stylebox_override("pressed", Style.box(Palette.PANEL, 24, Palette.AMBER, 4))
		b.add_theme_stylebox_override("hover_pressed", Style.box(Palette.PANEL, 24, Palette.AMBER, 4))
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.pressed.connect(_pick_avatar.bind(i))
		add_child(b)
		var v := ArtView.new()
		v.kind = "avatar"
		v.index = i
		v.position = b.position
		v.size = Vector2(170, 190)
		add_child(v)

	# right panel
	add_card(Rect2(660, 60, 560, 600))
	_preview = add_art("avatar", Rect2(720, 74, 440, 270), _avatar)

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
		b.pressed.connect(func() -> void: _country = c)
		x += 92.0
	add_lbl(I18n.t("country." + _country), Vector2(700, 526), 480, 16, Palette.TEAL, Style.font_body_bold)

	add_lbl(I18n.t("setup.language"), Vector2(700, 556), 0, 14, Palette.MUTED, Style.font_body_bold)
	var lg := ButtonGroup.new()
	x = 700.0
	for loc in I18n.LOCALES:
		var b := _toggle("Deutsch" if loc == "de" else "English", Vector2(x, 580), Vector2(118, 40), lg, loc == I18n.locale)
		b.pressed.connect(func() -> void: I18n.set_locale(loc))
		x += 130.0

	var cb := add_btn(I18n.t("common.continue"), Vector2(0, 592), _continue, "PrimaryButton", Vector2(160, 52))
	cb.position.x = 1196.0 - cb.size.x


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


func _pick_avatar(i: int) -> void:
	_avatar = i
	_preview.index = i
	_preview.queue_redraw()


func _continue() -> void:
	var nm := _name.strip_edges()
	if nm == "":
		nm = "Player" if I18n.locale == "en" else "Spieler"
	Game.begin_new_game(nm, _avatar, _country)
	SceneManager.go("hub")
