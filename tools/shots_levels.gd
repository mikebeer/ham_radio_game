extends SceneTree
## Screenshots of the level screens: xvfb-run godot --path . --rendering-driver opengl3 --script tools/shots_levels.gd

func _snap(name: String, frames: int = 15) -> void:
	for i in frames:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("/home/claude/shots/godot/%s.png" % name)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/home/claude/shots/godot")
	for i in 5:
		await process_frame
	var g = root.get_node("Game")
	var fd = root.get_node("FactDatabase")
	g.begin_new_game("Mika", 2, "de")
	g.set_callsign("DN1TST")
	for k in ["rules.lessons_all", "rules.quiz_passed", "qso.tuned", "qso.answered", "qso.exchanged", "qso.spelled", "qso.done"]:
		fd.set_fact(k, true)
	for id in g.PART_IDS:
		fd.set_fact("shack." + id, true)
	fd.set_fact("morse.passed", 3)
	for i in 3:
		await process_frame
	g.check_level_up()
	fd.set_fact("l2.shack.psu", true)
	fd.set_fact("l2.shack.antenna", true)
	var hub = (load("res://scenes/hub.tscn") as PackedScene).instantiate()
	root.add_child(hub)
	await _snap("lv_hub")
	hub._show_levelup(2)
	await _snap("lv_up")
	hub.queue_free()
	await process_frame
	for n in ["legal", "build", "morse"]:
		if n == "build":
			root.get_node("SceneManager").params = {"part": "swr"}
		var s = (load("res://scenes/%s.tscn" % n) as PackedScene).instantiate()
		root.add_child(s)
		await _snap("lv_" + n)
		if n == "legal":
			s._step = 5
			s._rebuild()
			await _snap("lv_legal_quiz")
		if n == "build":
			s._state = "quiz"
			s._rebuild()
			await _snap("lv_build_quiz")
		s.queue_free()
		await process_frame
	quit()
