extends SceneTree
## Rasterizes the 50ohm drawings (SVG) and photos used by the lesson cards into assets/course/*.png.
## Run: godot --headless --path . --script tools/rasterize_course.gd [path/to/50ohm-contents-dl]
## Names: d<ID>.png for drawings, p<ID>.png for photos. Licence: CC BY 4.0, DARC e.V. / 50ohm.de.

const MAX_W := 900
const MAX_H := 600


func _init() -> void:
	var src := "res://../src/50ohm-contents-dl/contents"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		src = args[0]
	var list = JSON.parse_string(FileAccess.get_file_as_string("res://tools/course/_images.json"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/course"))
	var n := 0
	for e in list:
		var kind: String = e[0]
		var id: String = e[1]
		var img := Image.new()
		if kind == "drawing":
			var bytes := FileAccess.get_file_as_bytes("%s/drawings/%s.svg" % [src, id])
			if bytes.is_empty() or img.load_svg_from_buffer(bytes, 1.0) != OK:
				push_error("svg %s" % id)
				continue
			var s := clampf(float(MAX_W) / float(img.get_width()), 1.0, 5.0)
			s = minf(s, float(MAX_H) / float(img.get_height()))
			if s > 1.05:
				img.load_svg_from_buffer(bytes, s)
		else:
			if img.load("%s/photos/%s.png" % [src, id]) != OK:
				push_error("photo %s" % id)
				continue
			if img.get_width() > MAX_W or img.get_height() > MAX_H:
				var f := minf(float(MAX_W) / img.get_width(), float(MAX_H) / img.get_height())
				img.resize(int(img.get_width() * f), int(img.get_height() * f), Image.INTERPOLATE_LANCZOS)
		img.save_png("res://assets/course/%s%s.png" % [kind[0], id])
		n += 1
	print("rasterized ", n)
	quit()
