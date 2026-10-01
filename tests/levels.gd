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
	for c in ["de", "us", "uk", "at"]:
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
	# avatar look, statistics, badges, languages, library
	var look: Dictionary = load("res://scripts/art/AvatarArt.gd").default_look()
	look["beard"] = 3
	look["skin"] = 7
	g.begin_new_game("T", look, "de")
	_check(g.look()["beard"] == 3 and g.look()["skin"] == 7, "look is stored")
	g.stat_add("correct", 50)
	_check(g.badge_earned("quiz50"), "badge quiz50")
	_check(not g.badge_earned("full_shack"), "no full shack yet")
	var ui = JSON.parse_string(FileAccess.get_file_as_string("res://content/i18n/ui.json"))
	for loc in root.get_node("I18n").LOCALES:
		for key in ui:
			_check(ui[key].has(loc), "ui key %s has %s" % [key, loc])
	_check(root.get_node("Content").library.size() > 100, "library loaded")
	for e in root.get_node("Content").library:
		for sid in e.get("see", []):
			_check(not root.get_node("Content").library_entry(sid).is_empty(), "library link " + str(sid))
	# lesson cards
	g.begin_new_game("T", 1, "de")
	for lv in [1, 2, 3]:
		for id in g.PART_IDS:
			var cards: Array = root.get_node("Content").part_tier(id, lv).get("cards", [])
			_check(cards.size() >= 4, "%s level %d has lesson cards" % [id, lv])
			for cd in cards:
				if cd.get("img", "") != "":
					_check(ResourceLoader.exists("res://assets/course/%s.png" % cd["img"]), "image " + str(cd["img"]))
		_check((g.level_data(lv)["lessons"] as Array).size() >= 8, "de rules lessons level %d" % lv)
	# Austria: band-specific content
	g.begin_new_game("T", 1, "at")
	_check(root.get_node("Content").part_tier("antenna", 1)["lesson"]["en"].contains("2 m"), "at class 3 antenna is 2 m / 70 cm")
	_check(root.get_node("Content").part_tier("antenna", 2)["lesson"]["en"].contains("80 m"), "at class 4 antenna mentions 80 m")
	_check(root.get_node("Content").qso_steps(1).size() == 3 and root.get_node("Content").qso_steps(2).size() == 3, "at qso steps")
	# countries with one level
	g.begin_new_game("T", 1, "ch")
	_check(g.level_count() == 1, "ch has 1 level")
	await _finish_level(g, 1)
	_check(g.check_level_up() == 0, "no level up without content")
	print("LEVELS OK")
	quit()
