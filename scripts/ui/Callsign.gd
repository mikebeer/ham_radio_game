extends Screen
## Goal 1, last step: find a free callsign in a fictional directory for your country.

var _book: Dictionary
var _choice := ""
var _edit: LineEdit
var _take: Button


func _build() -> void:
	_book = Content.callsign_book(Game.country())
	add_bg()
	add_header(I18n.t("callsign.title"), I18n.t("callsign.sub", [I18n.t("country." + Game.country()), _book.get("prefix", "")]))

	# left: how callsigns work
	add_card(Rect2(60, 120, 540, 500))
	add_title(I18n.t("callsign.explain_title"), Vector2(92, 144), 26, Palette.AMBER, 476)
	add_lbl(I18n.t("callsign.explain", [_book.get("prefix", "")]), Vector2(92, 190), 476, 17, Palette.MUTED)
	add_lbl(I18n.t("callsign.format", [_book.get("example", "")]), Vector2(92, 330), 476, 15, Palette.MUTED, Style.font_body_bold)
	_format_chips(Vector2(92, 360))
	add_lbl(I18n.t("callsign.wish"), Vector2(92, 440), 476, 15, Palette.MUTED, Style.font_body_bold)
	_edit = LineEdit.new()
	_edit.position = Vector2(92, 466)
	_edit.size = Vector2(300, 48)
	_edit.custom_minimum_size = Vector2(300, 48)
	_edit.max_length = 10
	_edit.placeholder_text = str(_book.get("example", ""))
	_edit.text_submitted.connect(func(_t: String) -> void: _check_wish())
	add_child(_edit)
	add_btn(I18n.t("callsign.check"), Vector2(408, 466), _check_wish, "", Vector2(160, 48))
	add_lbl(I18n.t("callsign.fiction"), Vector2(92, 548), 476, 12, Palette.MUTED)

	# right: directory
	add_card(Rect2(640, 120, 580, 500))
	add_lbl(I18n.t("callsign.dir"), Vector2(672, 142), 0, 14, Palette.MUTED, Style.font_body_bold)
	add_lbl(I18n.t("callsign.pick_hint"), Vector2(672, 164), 516, 14, Palette.TEAL, Style.font_body_bold)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(660, 196)
	scroll.size = Vector2(540, 340)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.custom_minimum_size = Vector2(520, 0)
	scroll.add_child(box)
	for e in _book.get("entries", []):
		box.add_child(_row(e))
	_take = add_btn("", Vector2(672, 556), _claim, "PrimaryButton", Vector2(516, 48))
	_update_take()


func _format_chips(pos: Vector2) -> void:
	# prefix | region digit | your letters, as colored blocks
	var ex := str(_book.get("example", ""))
	var pre := str(_book.get("prefix", ""))
	var parts: Array = []
	var cols: Array = []
	var d := 0
	while d < ex.length() and not ex[d].is_valid_int():
		d += 1
	if pre.length() > 0 and pre[pre.length() - 1].is_valid_int():
		parts = [pre, ex.substr(pre.length())]
		cols = [Palette.TEAL, Palette.GREEN]
	else:
		var n_pre := d if pre.contains("/") else pre.length()
		parts = [ex.substr(0, n_pre), ex.substr(n_pre, d + 1 - n_pre), ex.substr(d + 1)]
		cols = [Palette.TEAL, Palette.AMBER, Palette.GREEN]
	var x := pos.x
	for i in parts.size():
		var w: float = 34.0 * parts[i].length() + 28.0
		var p := Panel.new()
		p.position = Vector2(x, pos.y)
		p.size = Vector2(w, 56)
		p.add_theme_stylebox_override("panel", Style.box(cols[i], 14))
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(p)
		add_lbl(parts[i], Vector2(x, pos.y + 8), w, 28, Palette.INK, Style.font_mono, HORIZONTAL_ALIGNMENT_CENTER)
		x += w + 8.0


func _row(e: Dictionary) -> Button:
	var call: String = e["call"]
	var free := not e.has("name")
	var b := Button.new()
	b.custom_minimum_size = Vector2(520, 40)
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var sel := (call == _choice)
	b.add_theme_stylebox_override("normal", Style.box(Art.fade(Palette.AMBER, 0.25) if sel else Palette.PANEL2, 12, Palette.AMBER if sel else Palette.LINE, 2 if sel else 1))
	b.add_theme_stylebox_override("hover", Style.box(Palette.LINE, 12, Palette.MUTED, 1))
	b.add_theme_stylebox_override("pressed", Style.box(Palette.PANEL, 12, Palette.AMBER, 2))
	b.pressed.connect(_on_row.bind(e))
	var c := Style.label(call, 20, Palette.CREAM if free else Palette.MUTED, Style.font_mono)
	c.position = Vector2(14, 6)
	b.add_child(c)
	var t := Style.label(I18n.t("callsign.free") if free else "%s · %s" % [e["name"], e["qth"]], 16, Palette.GREEN if free else Palette.MUTED, Style.font_body_bold)
	t.position = Vector2(170, 9)
	b.add_child(t)
	return b


func _on_row(e: Dictionary) -> void:
	Sfx.click()
	if e.has("name"):
		Sfx.bad()
		toast(I18n.t("callsign.taken_toast", [e["call"], e["name"]]), Palette.CORAL)
		return
	_choice = e["call"]
	_rebuild()


func _check_wish() -> void:
	var call := _edit.text.strip_edges().to_upper()
	var re := RegEx.create_from_string(str(_book.get("pattern", "^$")))
	if re.search(call) == null:
		Sfx.bad()
		toast(I18n.t("callsign.bad_format", [_book.get("example", "")]), Palette.CORAL)
		return
	for e in _book.get("entries", []):
		if e["call"] == call and e.has("name"):
			Sfx.bad()
			toast(I18n.t("callsign.wish_taken", [call]), Palette.CORAL)
			return
	Sfx.good()
	_choice = call
	_rebuild()
	_edit.text = call


func _update_take() -> void:
	_take.visible = _choice != ""
	_take.text = I18n.t("callsign.take", [_choice])
	_take.size = Vector2(516, 48)


func _claim() -> void:
	if _choice == "":
		return
	Game.set_callsign(_choice)
	Sfx.reward()
	if Game.rules_done():
		SceneManager.go("hub", {"goal": "rules"})
	else:
		SceneManager.go("hub")
