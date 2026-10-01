extends Screen
## The library: look up ham radio terms (FT8, SWR, Q-codes ...). Search, filter by topic, jump between related terms.

var _query := ""
var _cat := ""
var _sel := ""
var _list: VBoxContainer
var _detail_box: Control


func _build() -> void:
	add_bg()
	add_header(I18n.t("library.title"), I18n.t("library.sub", [Content.library.size()]))
	add_card(Rect2(60, 120, 440, 500))
	add_card(Rect2(520, 120, 700, 500))

	var edit := LineEdit.new()
	edit.position = Vector2(80, 136)
	edit.size = Vector2(400, 44)
	edit.custom_minimum_size = Vector2(400, 44)
	edit.placeholder_text = I18n.t("library.search")
	edit.text = _query
	edit.clear_button_enabled = true
	edit.text_changed.connect(func(t: String) -> void:
		_query = t
		_fill_list())
	add_child(edit)

	var opt := OptionButton.new()
	opt.position = Vector2(80, 188)
	opt.size = Vector2(400, 40)
	opt.custom_minimum_size = Vector2(400, 40)
	opt.add_item(I18n.t("library.all"), 0)
	var cats := Content.library_categories()
	for i in cats.size():
		opt.add_item(I18n.t("cat." + cats[i]), i + 1)
		if cats[i] == _cat:
			opt.select(i + 1)
	opt.item_selected.connect(func(idx: int) -> void:
		_cat = "" if idx == 0 else cats[idx - 1]
		_fill_list())
	add_child(opt)

	var sc := ScrollContainer.new()
	sc.position = Vector2(76, 240)
	sc.size = Vector2(416, 368)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(sc)
	_list = VBoxContainer.new()
	_list.custom_minimum_size.x = 404
	_list.add_theme_constant_override("separation", 4)
	sc.add_child(_list)

	_detail_box = Control.new()
	_detail_box.position = Vector2(548, 140)
	_detail_box.size = Vector2(644, 464)
	add_child(_detail_box)
	if _sel == "" and Content.library.size() > 0:
		_sel = "swr" if Content.library_entry("swr").size() > 0 else str(Content.library[0]["id"])
	_fill_list()
	_show_entry(_sel)


func _matches(e: Dictionary) -> bool:
	if _cat != "" and e.get("cat", "") != _cat:
		return false
	if _query.strip_edges() == "":
		return true
	var q := _query.strip_edges().to_lower()
	return str(e.get("term", "")).to_lower().contains(q) or str(e.get("id", "")).contains(q) \
		or I18n.loc(e.get("name", "")).to_lower().contains(q) or I18n.loc(e.get("text", "")).to_lower().contains(q)


func _fill_list() -> void:
	for c in _list.get_children():
		c.queue_free()
	var n := 0
	for e in Content.library:
		if not _matches(e):
			continue
		n += 1
		var on: bool = e["id"] == _sel
		var b := Button.new()
		b.text = str(e["term"])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(396, 40)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 17)
		b.add_theme_stylebox_override("normal", Style.box(Palette.AMBER if on else Palette.PANEL2, 12, Palette.CLEAR if on else Palette.LINE, 0 if on else 1, Vector2(14, 6)))
		b.add_theme_stylebox_override("hover", Style.box(Palette.AMBER if on else Palette.LINE, 12, Palette.CLEAR, 0, Vector2(14, 6)))
		b.add_theme_color_override("font_color", Palette.INK if on else Palette.CREAM)
		b.add_theme_color_override("font_hover_color", Palette.INK if on else Palette.CREAM)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var id: String = e["id"]
		b.pressed.connect(func() -> void:
			Sfx.click()
			_sel = id
			_fill_list()
			_show_entry(id))
		_list.add_child(b)
	if n == 0:
		_list.add_child(Style.label(I18n.t("library.empty"), 16, Palette.MUTED))


func _show_entry(id: String) -> void:
	for c in _detail_box.get_children():
		c.queue_free()
	var e := Content.library_entry(id)
	if e.is_empty():
		return
	var w := 640.0
	var t := Style.label(str(e["term"]), 44, Palette.AMBER, Style.font_display)
	t.position = Vector2(0, 0)
	_detail_box.add_child(t)
	var y := 62.0
	var nm := I18n.loc(e.get("name", ""))
	if nm != "":
		var n := Style.label(nm, 20, Palette.CREAM, Style.font_body_bold)
		n.position = Vector2(0, y)
		_detail_box.add_child(n)
		y += 34.0
	var tag := Style.label("%s · %s" % [I18n.t("cat." + str(e.get("cat", ""))), I18n.t("library.level%d" % int(e.get("level", 1)))], 14, Palette.TEAL, Style.font_body_bold)
	tag.position = Vector2(0, y)
	_detail_box.add_child(tag)
	y += 34.0
	var body := Style.label(I18n.loc(e.get("text", "")), 19, Palette.MUTED)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size.x = w
	body.position = Vector2(0, y)
	body.size = Vector2(w, 0)
	_detail_box.add_child(body)
	var see: Array = e.get("see", [])
	if see.size() > 0:
		var h := Style.label(I18n.t("library.see_also"), 14, Palette.MUTED, Style.font_body_bold)
		h.position = Vector2(0, 372)
		_detail_box.add_child(h)
		var x := 0.0
		var row_y := 398.0
		for sid in see:
			var se := Content.library_entry(str(sid))
			if se.is_empty():
				continue
			var b := Button.new()
			b.text = str(se["term"])
			b.focus_mode = Control.FOCUS_NONE
			b.add_theme_font_size_override("font_size", 16)
			b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var target: String = str(sid)
			b.pressed.connect(func() -> void:
				Sfx.click()
				_sel = target
				_query = ""
				_cat = ""
				_rebuild())
			_detail_box.add_child(b)
			b.size = b.get_combined_minimum_size()
			if x + b.size.x > w:
				x = 0.0
				row_y += 46.0
			b.position = Vector2(x, row_y)
			x += b.size.x + 8.0
