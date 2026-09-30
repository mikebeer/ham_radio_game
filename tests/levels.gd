extends SceneTree
## Plays through the level ladder headlessly: godot --headless --path . --script tests/levels.gd

func _check(cond: bool, msg: String) -> void:
	if not cond:
		push_error("FAILED: " + msg)
		print("FAILED: ", msg)
		quit(1)


func _finish_level(g, lv: int) -> void:
	var fd = root.get_node("FactDatabase")
	var kf := func(key: String) -> String: return key if lv == 1 else "l%d.%s" % [lv, key]
	fd.set_fact(kf.call("rules.lessons_all"), true)
	fd.set_fact(kf.call("rules.quiz_passed"), true)
	if lv == 1:
		g.set_callsign("DN1TST")
	for id in g.PART_IDS:
		fd.set_fact(kf.call("shack." + id), true)
	for s in ["tuned", "answered", "exchanged", "spelled", "done"]:
		fd.set_fact(kf.call("qso." + s), true)
	fd.set_fact("morse.passed", g.MORSE_CAP[lv - 1])
	for i in 3:
		await process_frame


func _initialize() -> void:
	for i in 5:
		await process_frame
	var g = root.get_node("Game")
	for c in ["de", "us", "uk"]:
		g.begin_new_game("T", 1, c)
		_check(g.level_count() == 3, c + " has 3 levels")
		_check(g.levels_unlocked() == 1, "starts at level 1")
		await _finish_level(g, 1)
		_check(g.level_done(1), c + " level 1 done")
		_check(g.check_level_up() == 2, c + " unlocks level 2")
		_check(g.cur_level() == 2 and not g.owns("psu"), "level 2 shack starts empty")
		_check(g.tier("psu") == 1, "tier 1 kept")
		# scenes at level 2
		for n in ["hub", "legal", "build", "qso", "morse"]:
			var s = (load("res://scenes/%s.tscn" % n) as PackedScene).instantiate()
			if n == "build":
				root.get_node("SceneManager").params = {"part": "psu"}
			root.add_child(s)
			for i in 3:
				await process_frame
			s.queue_free()
			await process_frame
		await _finish_level(g, 2)
		_check(g.check_level_up() == 3, c + " unlocks level 3")
		var d3: Dictionary = root.get_node("Content").part_tier("swr", 3)
		_check((d3["questions"] as Array).size() == 4, "tier 3 swr has 4 questions")
		_check(root.get_node("Content").qso_steps(3).size() == 3, "level 3 qso steps")
		await _finish_level(g, 3)
		_check(g.level_done(3) and g.check_level_up() == 0, c + " all levels done")
	# countries with one level
	g.begin_new_game("T", 1, "ch")
	_check(g.level_count() == 1, "ch has 1 level")
	await _finish_level(g, 1)
	_check(g.check_level_up() == 0, "no level up without content")
	print("LEVELS OK")
	quit()
