extends SceneTree
## xvfb-run godot --path . --rendering-driver opengl3 --script tools/shots_audio.gd
## Fakes an installed voice so the Listen buttons show.

func _snap(name: String) -> void:
	for i in 10:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("/home/claude/shots/godot/%s.png" % name)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/home/claude/shots/godot")
	for i in 5:
		await process_frame
	root.get_node("Game").begin_new_game("Mika", 2, "at")
	root.get_node("Voice")._voices = {"demo": {"nato_alfa": true}}
	var m = (load("res://scenes/morse.tscn") as PackedScene).instantiate()
	root.add_child(m)
	await _snap("a_morse")
	m.queue_free()
	var s = (load("res://scenes/spell.tscn") as PackedScene).instantiate()
	root.add_child(s)
	await _snap("a_intro")
	s._start()
	s._i = 4
	s._begin_task()
	await _snap("a_decode")
	root.get_node("Game").set_flag("spell.audio_only", true)
	s._rebuild()
	await _snap("a_decode_audio")
	s._edit.text = "x"
	s._check()
	await _snap("a_feedback")
	s.queue_free()
	root.get_node("SceneManager").params = {"tab": "game"}
	var st = (load("res://scenes/settings.tscn") as PackedScene).instantiate()
	root.add_child(st)
	await _snap("a_settings")
	quit()
