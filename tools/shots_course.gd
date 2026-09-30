extends SceneTree
## Screenshots of lesson cards: xvfb-run godot --path . --rendering-driver opengl3 --script tools/shots_course.gd

func _snap(name: String, frames: int = 12) -> void:
	for i in frames:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("/home/claude/shots/godot/%s.png" % name)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/home/claude/shots/godot")
	for i in 5:
		await process_frame
	var g = root.get_node("Game")
	g.begin_new_game("Mika", 1, "de")
	var s = (load("res://scenes/legal.tscn") as PackedScene).instantiate()
	root.add_child(s)
	s._step = 11
	s._rebuild()
	await _snap("c_legal")
	s.queue_free()
	await process_frame
	for part in ["psu", "antenna", "swr"]:
		root.get_node("SceneManager").params = {"part": part}
		var b = (load("res://scenes/build.tscn") as PackedScene).instantiate()
		root.add_child(b)
		b._page = 1
		b._rebuild()
		await _snap("c_build_" + part)
		b.queue_free()
		await process_frame
	quit()
