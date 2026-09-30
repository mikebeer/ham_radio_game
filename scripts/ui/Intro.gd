extends Screen
## 2. Short introduction: three slides with a typewriter effect.

const SLIDES := 3

var _slide := 0
var _t := 0.0
var _art: Control
var _body: Label
var _typing: Tween


func _build() -> void:
	add_bg()
	add_card(Rect2(60, 40, 600, 370))
	_art = Control.new()
	_art.position = Vector2(60, 40)
	_art.size = Vector2(600, 370)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.draw.connect(_draw_art)
	add_child(_art)

	# right column: the four goals
	add_title(I18n.t("intro.3.t"), Vector2(720, 60), 40, Palette.AMBER, 500)
	var cols := [Palette.TEAL, Palette.AMBER, Palette.GREEN, Palette.CORAL]
	for i in 4:
		var dot := Panel.new()
		dot.position = Vector2(720, 150 + i * 62)
		dot.size = Vector2(40, 40)
		dot.add_theme_stylebox_override("panel", Style.box(cols[i], 20))
		add_child(dot)
		add_lbl(str(i + 1), Vector2(720, 154 + i * 62), 40, 20, Palette.INK, Style.font_display, HORIZONTAL_ALIGNMENT_CENTER)
		add_lbl(I18n.t("intro.goal%d" % (i + 1)), Vector2(780, 152 + i * 62), 440, 22, Palette.CREAM, Style.font_body_bold)

	# text box
	add_card(Rect2(60, 430, 1160, 170))
	add_title(I18n.t("intro.%d.t" % (_slide + 1)), Vector2(96, 452), 32, Palette.CREAM, 1088)
	_body = add_lbl(I18n.t("intro.%d.b" % (_slide + 1)), Vector2(96, 508), 1088, 20, Palette.MUTED)
	_type_body()

	# navigation
	for i in SLIDES:
		var d := Panel.new()
		d.position = Vector2(600 + i * 26, 650)
		d.size = Vector2(14, 14)
		d.add_theme_stylebox_override("panel", Style.box(Palette.AMBER if i == _slide else Palette.LINE, 7))
		add_child(d)
	add_btn(I18n.t("common.skip"), Vector2(60, 636), func() -> void: SceneManager.go("setup"))
	var nb := add_btn(I18n.t("common.next"), Vector2(0, 632), _next, "PrimaryButton", Vector2(160, 52))
	nb.position.x = 1220.0 - nb.size.x


func _type_body() -> void:
	if _typing:
		_typing.kill()
	_body.visible_ratio = 0.0
	_typing = create_tween()
	_typing.tween_property(_body, "visible_ratio", 1.0, maxf(0.6, _body.text.length() * 0.014))


func _next() -> void:
	if _body.visible_ratio < 1.0:
		_typing.kill()
		_body.visible_ratio = 1.0
		return
	if _slide < SLIDES - 1:
		_slide += 1
		_rebuild()
	else:
		SceneManager.go("setup")


func _process(delta: float) -> void:
	_t += delta
	if _art:
		_art.queue_redraw()


func _draw_art() -> void:
	var ci := _art
	Art.stars(ci, Rect2(20, 20, 560, 200), 20, _t, 5)
	match _slide:
		0:
			ci.draw_circle(Vector2(300, 170), 130, Art.fade(Palette.TEAL, 0.08))
			Art.rings(ci, Vector2(300, 170), _t, 3, 170.0, Palette.AMBER)
			Art.avatar(ci, Vector2(300, 175), 120.0, Game.profile.get("avatar", 1))
		1:
			ci.draw_rect(Rect2(0, 250, 600, 120), Palette.WOOD)
			Art.gear(ci, "transceiver", Rect2(150, 130, 300, 120))
			Art.gear(ci, "psu", Rect2(30, 160, 100, 90), 1.0, 0.0)
			Art.gear(ci, "speaker", Rect2(470, 120, 100, 130))
			Art.gear(ci, "antenna", Rect2(255, 14, 90, 110), 0.9)
		_:
			var ids := ["logbook", "key", "antenna", "mic"]
			for i in 4:
				var r := Rect2(40 + i * 140, 130, 120, 120)
				Art.rrect(ci, r, Palette.PANEL2, 20, Palette.LINE, 2)
				Art.gear(ci, ids[i], r.grow(-16))
