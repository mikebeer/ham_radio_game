class_name Screen
extends Control
## Base class for all screens. Screens build their UI in _build() with absolute coordinates
## (1280 x 720 design space, matching the Figma frames) and are rebuilt when the language changes.


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = Style.theme
	I18n.locale_changed.connect(_rebuild)
	_rebuild()


func _rebuild(_locale: String = "") -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_build()


func _build() -> void:
	pass


# ---- builders ---------------------------------------------------------------------------

func add_bg(color: Color = Palette.INK) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func add_lbl(text: String, pos: Vector2, width: float = 0.0, font_size: int = 18, color: Color = Palette.CREAM,
		font: Font = null, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Style.label(text, font_size, color, font)
	l.position = pos
	l.horizontal_alignment = align
	if width > 0.0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = width
		l.size.x = width
	add_child(l)
	if width > 0.0:
		l.size = Vector2(width, 0.0)
	return l


func add_title(text: String, pos: Vector2, font_size: int = 32, color: Color = Palette.CREAM, width: float = 0.0) -> Label:
	return add_lbl(text, pos, width, font_size, color, Style.font_display)


func add_btn(text: String, pos: Vector2, cb: Callable, variation: String = "", min_size: Vector2 = Vector2.ZERO) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	if variation != "":
		b.theme_type_variation = variation
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(func() -> void:
		Sfx.click()
		cb.call())
	add_child(b)
	b.size = b.get_combined_minimum_size().max(min_size)
	return b


func add_card(rect: Rect2, style: StyleBox = null) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	if style != null:
		p.add_theme_stylebox_override("panel", style)
	add_child(p)
	return p


func add_art(kind: String, rect: Rect2, index: int = 0, part: String = "") -> ArtView:
	var a := ArtView.new()
	a.kind = kind
	a.index = index
	a.part = part
	a.position = rect.position
	a.size = rect.size
	add_child(a)
	return a


## Back button plus title and subtitle, as on the Figma work screens.
func add_header(title: String, sub: String, back_scene: String = "hub", back_params: Dictionary = {}) -> Label:
	add_btn(I18n.t("common.back"), Vector2(40, 28), func() -> void: SceneManager.go(back_scene, back_params))
	add_btn(I18n.t("share.btn"), Vector2(1112, 28), Share.open, "", Vector2(108, 40))
	add_title(title, Vector2(190, 26), 32)
	return add_lbl(sub, Vector2(190, 70), 700, 16, Palette.MUTED)


func toast(text: String, color: Color = Palette.AMBER) -> void:
	var l := Style.display_label(text, 22, Palette.INK)
	var box := Style.box(color, 22, Palette.CLEAR, 0, Vector2(24, 12))
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box)
	p.add_child(l)
	add_child(p)
	p.position = Vector2(640.0 - p.get_combined_minimum_size().x / 2.0, 690)
	p.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(p, "position:y", 640.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(p, "modulate:a", 1.0, 0.2)
	t.tween_interval(2.4)
	t.tween_property(p, "modulate:a", 0.0, 0.4)
	t.tween_callback(p.queue_free)
