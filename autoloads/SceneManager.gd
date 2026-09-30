extends CanvasLayer
## Scene switching with a short fade. Parameters for the next scene are kept in `params`.

var params: Dictionary = {}
var _fade: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	_fade = ColorRect.new()
	_fade.color = Style.INK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	add_child(_fade)


func go(scene: String, p: Dictionary = {}) -> void:
	if _busy:
		return
	_busy = true
	params = p
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(_fade, "modulate:a", 1.0, 0.22)
	await t.finished
	var err := get_tree().change_scene_to_file("res://scenes/%s.tscn" % scene)
	if err != OK:
		push_error("SceneManager: cannot load scene '%s' (%d)" % [scene, err])
	await get_tree().process_frame
	await get_tree().process_frame
	var t2 := create_tween()
	t2.tween_property(_fade, "modulate:a", 0.0, 0.22)
	await t2.finished
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
