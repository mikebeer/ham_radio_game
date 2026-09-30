class_name GearView
extends Control
## One slot in the radio shack: a dashed placeholder until the part is earned, then the part.

signal pressed(part_id: String)

var part_id: String = ""
var owned := false:
	set(v):
		owned = v
		queue_redraw()
var glow := 0.0:
	set(v):
		glow = v
		queue_redraw()
var freq := "14.205"
var _hover := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(func() -> void:
		_hover = true
		queue_redraw())
	mouse_exited.connect(func() -> void:
		_hover = false
		queue_redraw())
	resized.connect(func() -> void: pivot_offset = size / 2.0)
	pivot_offset = size / 2.0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(part_id)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if owned:
		Art.gear(self, part_id, r, 1.0, glow, freq)
	else:
		Art.rrect(self, r, Palette.fade_ink(0.4), 16)
		Art.dashed_rect(self, r.grow(-1.0), Art.fade(Palette.MUTED, 0.9 if _hover else 0.6), 2.0, 8.0)
		var f := Style.font_display
		var fs := 34
		var text_size := f.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		draw_string(f, Vector2((size.x - text_size.x) / 2.0, size.y / 2.0 + fs * 0.35), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Art.fade(Palette.MUTED, 0.8 if _hover else 0.5))
	if _hover:
		Art.rrect(self, r.grow(4.0), Palette.CLEAR, 18, Palette.AMBER, 3)


## Drop-in animation used when a part is newly earned.
func pop() -> void:
	owned = true
	scale = Vector2(0.2, 0.2)
	modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 1.0, 0.25)
	glow = 1.0
	var g := create_tween()
	g.tween_property(self, "glow", 0.0, 1.6).set_delay(0.4)


func wiggle() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.06, 1.06), 0.1)
	t.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK)
