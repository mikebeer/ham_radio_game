extends SceneTree
## Screenshots of the new UI: xvfb-run godot --path . --rendering-driver opengl3 --script tools/shots_ui.gd

func _snap(name: String, frames: int = 12) -> void:
	for i in frames:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("/home/claude/shots/godot/%s_%s.png" % [name, root.get_node("I18n").locale])


func _show(scene: String, params: Dictionary = {}) -> Node:
	root.get_node("SceneManager").params = params
	var s = (load("res://scenes/%s.tscn" % scene) as PackedScene).instantiate()
	root.add_child(s)
	return s


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/home/claude/shots/godot")
	for i in 5:
		await process_frame
	var lang := "en"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		lang = args[0]
	root.get_node("I18n").set_locale(lang)
	var g = root.get_node("Game")
	var A = load("res://scripts/art/AvatarArt.gd")
	var look: Dictionary = A.default_look()
	look.merge({"skin": 5, "hair": 6, "haircol": 0, "beard": 3, "glasses": 1, "age": 2, "gender": 1}, true)
	g.begin_new_game("Mika", look, "at")
	g.set_callsign("OE1TST")
	g.stat_add("answers", 40)
	g.stat_add("correct", 33)
	g.stat_add("cards", 26)
	root.get_node("FactDatabase").set_fact("shack.psu", true)
	root.get_node("FactDatabase").set_fact("morse.passed", 4)
	var s = _show("setup", {"profile": true})
	await _snap("u_setup")
	s.queue_free()
	await process_frame
	for tab in ["profile", "stats", "badges", "language", "game"]:
		s = _show("settings", {"tab": tab})
		await _snap("u_settings_" + tab)
		s.queue_free()
		await process_frame
	s = _show("library")
	await _snap("u_library")
	s.queue_free()
	await process_frame
	s = _show("hub")
	await _snap("u_hub")
	s.queue_free()
	await process_frame
	s = _show("morse")
	await _snap("u_morse")
	quit()
