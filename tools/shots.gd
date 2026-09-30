extends SceneTree
## Screenshots of every screen: xvfb-run godot --path . --script tools/shots.gd -- outdir

func _initialize() -> void:
	var out := "/home/claude/shots/godot"
	DirAccess.make_dir_recursive_absolute(out)
	for i in 5:
		await process_frame
	var game = root.get_node("Game")
	game.begin_new_game("Mika", 2, "de")
	for id in ["psu", "antenna", "transceiver", "mic", "speaker", "key"]:
		game.award(id)
	game.set_flag("rules.quiz_passed", true)
	game.set_flag("goal.rules", true)
	for n in ["splash", "intro", "setup", "hub", "legal", "build", "qso", "morse"]:
		var s = (load("res://scenes/%s.tscn" % n) as PackedScene).instantiate()
		root.add_child(s)
		for i in 30:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, n])
		if n == "qso":
			s._slider.value = s._target
			for i in 20:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/qso_tuned.png" % out)
			s._stage = 1
			s._start_step(0)
			s._rebuild()
			for i in 10:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/qso_chat.png" % out)
		if n == "legal":
			s._step = 5
			s._rebuild()
			for i in 10:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/legal_quiz.png" % out)
		if n == "morse":
			s._mode = "send"
			s._rebuild()
			for i in 10:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/morse_send.png" % out)
		s.queue_free()
		await process_frame
	quit()
