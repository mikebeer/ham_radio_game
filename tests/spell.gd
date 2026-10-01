extends SceneTree
## Spelling trainer logic: godot --headless --path . --script tests/spell.gd

func _check(ok: bool, msg: String) -> void:
	if not ok:
		print("FAIL: ", msg)
		quit(1)


func _initialize() -> void:
	for i in 5:
		await process_frame
	var g = root.get_node("Game")
	g.begin_new_game("Jürgen Müller", 1, "at")
	var s = (load("res://scenes/spell.tscn") as PackedScene).instantiate()
	root.add_child(s)
	for i in 3:
		await process_frame
	_check(s._parse("Charlie alpha, X-ray  JULIET 7 nine") == ["C", "A", "X", "J", "7", "9"], "parse")
	_check(s._parse("Charly") == ["?"], "unknown word")
	_check(s.fold("Müller-Lüdenscheid ß") == "MULLERLUDENSCHEIDSS", "fold")
	s._start()
	await process_frame
	_check(s._tasks.size() == 6, "six tasks")
	_check(s._tasks[0]["answer"] == "JURGEN", "first task is the player's name: " + str(s._tasks[0]["answer"]))
	for i in 6:
		var t: Dictionary = s._tasks[i]
		var typed: String = " ".join(s._spoken(t["answer"])) if t["mode"] == "encode" else str(t["answer"])
		await process_frame
		s._edit.text = typed
		s._check()
		await process_frame
		_check(s._fb_ok, "task %d accepted: %s" % [i, typed])
		if i < 5:
			s._i += 1
			s._begin_task()
			await process_frame
	s._finish()
	await process_frame
	_check(g.fact_int("spell.best") == 6 and g.badge_earned("spell"), "badge and best score")
	# a wrong answer is rejected
	s._start()
	await process_frame
	s._edit.text = "Alfa Alfa"
	s._check()
	_check(not s._fb_ok, "wrong answer rejected")
	print("SPELL OK")
	quit()
