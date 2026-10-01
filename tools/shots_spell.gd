extends SceneTree
## xvfb-run godot --path . --rendering-driver opengl3 --script tools/shots_spell.gd

func _snap(name: String) -> void:
	for i in 10:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("/home/claude/shots/godot/%s.png" % name)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/home/claude/shots/godot")
	for i in 5:
		await process_frame
	root.get_node("Game").begin_new_game("Mika", 2, "at")
	var s = (load("res://scenes/spell.tscn") as PackedScene).instantiate()
	root.add_child(s)
	await _snap("s_intro")
	s._start()
	await _snap("s_ask")
	s._edit.text = "Mike India"
	s._hint = true
	s._rebuild()
	await _snap("s_hint")
	s._i = 4
	s._begin_task()
	await _snap("s_decode")
	s._edit.text = "x"
	s._check()
	await _snap("s_feedback")
	quit()
