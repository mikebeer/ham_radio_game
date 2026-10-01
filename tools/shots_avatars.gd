extends SceneTree
## Contact sheet of random avatars: xvfb-run godot --path . --rendering-driver opengl3 --script tools/shots_avatars.gd


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("/home/claude/shots/godot")
	var A = load("res://scripts/art/AvatarArt.gd")
	var s := Control.new()
	s.size = Vector2(1280, 720)
	s.draw.connect(func() -> void:
		s.draw_rect(Rect2(Vector2.ZERO, s.size), Color("1B2A41"))
		var rng := RandomNumberGenerator.new()
		rng.seed = 42
		for i in 40:
			var l: Dictionary = A.random_look(rng)
			if i < 6:
				l = A.preset(i)
			A.draw(s, Vector2(80 + (i % 10) * 124, 80 + (i / 10) * 150), 76.0, l))
	root.add_child(s)
	for i in 8:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("/home/claude/shots/godot/avatars.png")
	quit()
