extends SceneTree
## Plays through QSO, Morse and Legal logic headlessly: godot --headless --path . --script tests/flow.gd

func _initialize() -> void:
	for i in 5:
		await process_frame
	var g = root.get_node("Game")
	g.begin_new_game("Tester", 1, "de")
	for id in g.PART_IDS:
		g.award(id)
	g.set_flag("goal.rules", true)
	var cb = (load("res://scenes/callsign.tscn") as PackedScene).instantiate()
	root.add_child(cb)
	await process_frame
	var free_call := ""
	for e in cb._book["entries"]:
		if not e.has("name"):
			free_call = e["call"]
			break
	cb._on_row({"call": "X", "name": "Taken T.", "qth": "Nowhere"})
	assert(cb._choice == "")
	cb._on_row({"call": free_call})
	assert(cb._choice == free_call)
	cb._edit.text = "XX9"
	cb._check_wish()
	assert(cb._choice == free_call)
	cb.queue_free()
	g.set_callsign(free_call)
	assert(g.has_callsign() and g.callsign() == free_call)
	g.change_country("at")
	assert(not g.has_callsign() and g.country() == "at")
	g.change_country("de")
	g.set_flag("goal.rules", true)
	var q = (load("res://scenes/qso.tscn") as PackedScene).instantiate()
	root.add_child(q)
	await process_frame
	q._slider.value = q._target
	for i in 3:
		await process_frame
	assert(q._tuned)
	q._stage = 1
	q._start_step(0)
	for st in [0, 1]:
		q._on_choice(st, 0)
		await process_frame
	assert(q._stage == 3)
	for i in g.callsign().length():
		q._on_spell(q.NATO[g.callsign()[q._spell_i]])
		await process_frame
	assert(q._stage == 4)
	q._on_choice(2, 0)
	assert(q._stage == 5)
	assert(g.qso_steps_done() >= 3)
	q.queue_free()
	var m = (load("res://scenes/morse.tscn") as PackedScene).instantiate()
	root.add_child(m)
	await process_frame
	for r in 10:
		m._on_pick(m._target)
		m._after_pick()
		await process_frame
	assert(m._mode == "result" and m._passed)
	assert(g.morse_passed() == 1)
	print("FLOW OK")
	quit()
