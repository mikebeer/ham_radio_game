class_name ArtView
extends Control
## A Control that shows one vector illustration: an avatar or a shack part.

@export var kind: String = "avatar"  # "avatar" or "gear"
@export var index: int = 0
@export var part: String = ""
var look: Dictionary = {}

var glow := 0.0:
	set(v):
		glow = v
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	match kind:
		"avatar":
			var s := minf(size.x * 0.55, size.y * 0.5)
			Art.avatar(self, Vector2(size.x * 0.5, size.y * 0.4), s, look if not look.is_empty() else index)
		"gear":
			Art.gear(self, part, Rect2(Vector2.ZERO, size), 1.0, glow)
