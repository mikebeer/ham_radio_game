class_name IconButton
extends Button
## Round-cornered button with a code-drawn icon: "back", "share", "settings", "library".

@export var kind := "back"


func _init() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(52, 46)
	size = Vector2(52, 46)
	add_theme_stylebox_override("normal", Style.box(Palette.PANEL2, 16, Palette.LINE, 1, Vector2(0, 0)))
	add_theme_stylebox_override("hover", Style.box(Palette.LINE, 16, Palette.MUTED, 1, Vector2(0, 0)))
	add_theme_stylebox_override("pressed", Style.box(Palette.PANEL, 16, Palette.AMBER, 2, Vector2(0, 0)))
	pressed.connect(Sfx.click)


func _draw() -> void:
	var c := size * 0.5
	var col: Color = Palette.CREAM if not is_hovered() else Palette.AMBER
	var w := 3.0
	match kind:
		"back":
			draw_line(c + Vector2(12, 0), c + Vector2(-12, 0), col, w, true)
			draw_polyline(PackedVector2Array([c + Vector2(-2, -10), c + Vector2(-12, 0), c + Vector2(-2, 10)]), col, w, true)
		"prev":
			draw_polyline(PackedVector2Array([c + Vector2(4, -9), c + Vector2(-5, 0), c + Vector2(4, 9)]), col, w, true)
		"next":
			draw_polyline(PackedVector2Array([c + Vector2(-4, -9), c + Vector2(5, 0), c + Vector2(-4, 9)]), col, w, true)
		"share":
			var a := c + Vector2(-9, 0)
			var b := c + Vector2(9, -9)
			var d := c + Vector2(9, 9)
			draw_line(a, b, col, 2.5, true)
			draw_line(a, d, col, 2.5, true)
			for p in [a, b, d]:
				draw_circle(p, 5.0, col)
		"settings":
			for i in 8:
				var ang := float(i) * TAU / 8.0
				draw_line(c + Vector2(cos(ang), sin(ang)) * 10.0, c + Vector2(cos(ang), sin(ang)) * 14.0, col, 4.0, true)
			draw_arc(c, 10.0, 0.0, TAU, 32, col, 3.0, true)
			draw_circle(c, 4.0, col)
		"library":
			draw_polyline(PackedVector2Array([c + Vector2(0, -9), c + Vector2(-13, -12), c + Vector2(-13, 10), c + Vector2(0, 13)]), col, 2.5, true)
			draw_polyline(PackedVector2Array([c + Vector2(0, -9), c + Vector2(13, -12), c + Vector2(13, 10), c + Vector2(0, 13)]), col, 2.5, true)
			draw_line(c + Vector2(0, -9), c + Vector2(0, 13), col, 2.5, true)
