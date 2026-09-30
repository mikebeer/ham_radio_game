extends Screen
## 1. Splash: night sky, a mast sending out signal rings, the game title.

var _t := 0.0
var _scenery: Control
var _started := false


func _build() -> void:
	add_bg()
	_scenery = Control.new()
	_scenery.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scenery.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scenery.draw.connect(_draw_scenery)
	add_child(_scenery)

	add_lbl(I18n.t("app.title"), Vector2(0, 352), 1280, 96, Palette.CREAM, Style.font_display, HORIZONTAL_ALIGNMENT_CENTER)
	add_lbl(I18n.t("app.tagline"), Vector2(0, 486), 1280, 26, Palette.AMBER, Style.font_body_bold, HORIZONTAL_ALIGNMENT_CENTER)

	var start := add_btn(I18n.t("splash.start"), Vector2(0, 622), _start, "PrimaryButton", Vector2(280, 56))
	start.position.x = 500.0
	var pulse := start.create_tween().set_loops()
	start.pivot_offset = Vector2(140, 28)
	pulse.tween_property(start, "scale", Vector2(1.05, 1.05), 0.9).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(start, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)

	# language switch
	var x := 1120.0
	for loc in I18n.LOCALES:
		var b := add_btn(loc.to_upper(), Vector2(x, 660), func() -> void: I18n.set_locale(loc),
				"PrimaryButton" if loc == I18n.locale else "", Vector2(64, 40))
		x += 72.0
	add_lbl("v0.1", Vector2(32, 682), 0, 14, Palette.MUTED, Style.font_mono)


func _process(delta: float) -> void:
	_t += delta
	if _scenery:
		_scenery.queue_redraw()


func _draw_scenery() -> void:
	var ci := _scenery
	Art.stars(ci, Rect2(20, 10, 1240, 320), 46, _t, 11)
	ci.draw_circle(Vector2(640, 730), 400, Art.fade(Palette.PANEL, 0.6))
	Art.rings(ci, Vector2(640, 146), _t, 4, 330.0)
	ci.draw_rect(Rect2(0, 590, 1280, 130), Palette.PANEL)
	ci.draw_rect(Rect2(0, 590, 1280, 6), Palette.LINE)
	Art.rrect(ci, Rect2(632, 160, 16, 210), Palette.LINE, 4)
	for i in 3:
		Art.rrect(ci, Rect2(600 + i * 6, 196 + i * 50, 80 - i * 12, 8), Palette.AMBER, 4)
	var glow := 0.16 + 0.06 * sin(_t * 3.0)
	ci.draw_circle(Vector2(640, 146), 46.0, Art.fade(Palette.AMBER, glow))
	ci.draw_circle(Vector2(640, 146), 16.0, Palette.AMBER)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		_start()


func _start() -> void:
	if _started:
		return
	_started = true
	SceneManager.go("hub" if Game.has_save() else "intro")
