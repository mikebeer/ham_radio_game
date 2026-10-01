extends SceneTree
## Headless smoke test: godot --headless --path . --script tools/smoke.gd

func _initialize() -> void:
	for i in 5:
		await process_frame
	var game = root.get_node("Game")
	game.begin_new_game("Tester", 2, "de")
	for id in game.PART_IDS:
		game.award(id)
	game.set_flag("rules.quiz_passed", true)
	for n in ["splash", "intro", "setup", "hub", "callsign", "legal", "build", "qso", "morse", "settings", "library"]:
		var packed: PackedScene = load("res://scenes/%s.tscn" % n)
		var s = packed.instantiate()
		root.add_child(s)
		for i in 5:
			await process_frame
		print("OK scene ", n)
		for loc in ["de", "en"]:
			root.get_node("I18n").set_locale(loc)
			await process_frame
		s.queue_free()
		await process_frame
	for c in ["us", "uk", "ch", "at"]:
		game.profile["country"] = c
		var s = (load("res://scenes/legal.tscn") as PackedScene).instantiate()
		root.add_child(s)
		await process_frame
		await process_frame
		s.queue_free()
		await process_frame
	print("SMOKE DONE")
	quit()
