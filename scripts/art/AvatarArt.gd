class_name AvatarArt
extends RefCounted
## Composable avatar, drawn with code. A "look" is a Dictionary of small integers:
##   skin 0-7, age 0-2 (young, adult, senior), gender 0-2 (female, male, neutral),
##   hair 0-10 (style), haircol 0-8, beard 0-6, glasses 0-4, hat 0-3, shirt 0-7, headset 0-1.
## draw() takes the head centre `c` and the head diameter `s`.

const SKINS := ["F6D5BE", "EBC09B", "DDA777", "C68E5F", "A86F45", "8A5636", "6B4128", "4A2D1C"]
const HAIRS := ["1E1A1A", "3B2A20", "6B4A2F", "D9B66B", "A8472A", "9A9A9A", "EDEDED", "3A6FD8", "E26FA0"]
const SHIRTS := ["2EC4B6", "FF6B6B", "7FD99A", "FFB84D", "8B5E3C", "8A97B5", "8E6BD6", "3F8CE0"]

const COUNTS := {"skin": 8, "age": 3, "gender": 3, "hair": 11, "haircol": 9, "beard": 7, "glasses": 5, "hat": 4, "shirt": 8, "headset": 2}
const ORDER := ["skin", "age", "gender", "hair", "haircol", "beard", "glasses", "hat", "shirt", "headset"]


static func default_look() -> Dictionary:
	return {"skin": 1, "age": 1, "gender": 2, "hair": 1, "haircol": 1, "beard": 0, "glasses": 0, "hat": 0, "shirt": 0, "headset": 1}


## Look for the six original preset avatars (older saves stored an index).
static func preset(idx: int) -> Dictionary:
	var i := posmod(idx, 6)
	var l := default_look()
	l["skin"] = [1, 3, 5, 0, 4, 6][i]
	l["hair"] = [1, 6, 8, 3, 4, 7][i]
	l["haircol"] = [1, 0, 2, 4, 7, 5][i]
	l["shirt"] = i
	l["gender"] = [2, 0, 1, 0, 2, 1][i]
	return l


static func random_look(rng: RandomNumberGenerator) -> Dictionary:
	var l := {}
	for k in ORDER:
		l[k] = rng.randi_range(0, int(COUNTS[k]) - 1)
	l["headset"] = 1
	l["hat"] = 0 if rng.randf() < 0.7 else l["hat"]
	l["glasses"] = 0 if rng.randf() < 0.6 else l["glasses"]
	l["beard"] = 0 if (rng.randf() < 0.6 or l["gender"] == 0) else l["beard"]
	return l


static func sanitize(l: Dictionary) -> Dictionary:
	var out := default_look()
	for k in ORDER:
		if l.has(k):
			out[k] = clampi(int(l[k]), 0, int(COUNTS[k]) - 1)
	return out


static func _p(c: Vector2, s: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * s


static func _cap(ci: CanvasItem, c: Vector2, s: float, col: Color, radius: float, base: float, curve: float, tilt: float = 0.0) -> void:
	var pts := PackedVector2Array()
	for k in 25:
		var a := PI + PI * float(k) / 24.0
		pts.append(_p(c, s, cos(a) * radius, sin(a) * radius))
	for k in 17:
		var x := 0.5 - float(k) / 16.0
		var u := x / 0.5
		var xx := x * radius / 0.5 * 0.98
		var arc_y := -sqrt(maxf(0.0, radius * radius - xx * xx))
		pts.append(_p(c, s, xx, maxf(base + curve * u * u + tilt * u, arc_y + 0.04)))
	ci.draw_colored_polygon(pts, col)


static func _poly(ci: CanvasItem, c: Vector2, s: float, pts: Array, col: Color) -> void:
	var out := PackedVector2Array()
	for p in pts:
		out.append(_p(c, s, p[0], p[1]))
	ci.draw_colored_polygon(out, col)


static func draw(ci: CanvasItem, c: Vector2, s: float, look_in) -> void:
	var look: Dictionary
	if look_in is Dictionary:
		look = sanitize(look_in)
	else:
		look = preset(int(look_in))
	var skin := Color(SKINS[look["skin"]])
	var skin_d := skin.darkened(0.14)
	var hair := Color(HAIRS[look["haircol"]])
	var shirt := Color(SHIRTS[look["shirt"]])
	var ink := Palette.INK
	var style: int = look["hair"]
	var hat: int = look["hat"]
	var gender: int = look["gender"]
	var age: int = look["age"]
	var lw := maxf(2.0, s * 0.03)

	# hair behind the head
	if style == 5 and hat == 0:
		ci.draw_circle(_p(c, s, 0, -0.12), s * 0.68, hair)
	if style == 6 or style == 9 or style == 7:
		var down := 0.72 if style == 6 else (0.34 if style == 9 else 0.1)
		if style == 7:
			ci.draw_circle(_p(c, s, 0.5, -0.02), s * 0.14, hair)
			Art.rrect(ci, Rect2(_p(c, s, 0.46, -0.02), Vector2(0.16, 0.5) * s), hair, s * 0.08)
		else:
			Art.rrect(ci, Rect2(_p(c, s, -0.56, -0.2), Vector2(1.12, down + 0.2) * s), hair, s * 0.28)
	if style == 8 and hat == 0:
		ci.draw_circle(_p(c, s, 0, -0.62), s * 0.17, hair)
	if style == 10 and hat == 0:
		_poly(ci, c, s, [[-0.1, -0.4], [-0.08, -0.82], [0.0, -0.9], [0.08, -0.82], [0.1, -0.4]], hair)

	# body, neck
	Art.rrect(ci, Rect2(c.x - s * 0.7, c.y + s * 0.42, s * 1.4, s * 0.85), shirt, s * 0.35)
	Art.rrect(ci, Rect2(c.x - s * 0.12, c.y + s * 0.38, s * 0.24, s * 0.2), skin_d, s * 0.06)
	_poly(ci, c, s, [[-0.14, 0.5], [0.0, 0.62], [0.14, 0.5]], skin_d)
	# ears
	ci.draw_circle(_p(c, s, -0.5, 0.04), s * 0.07, skin_d)
	ci.draw_circle(_p(c, s, 0.5, 0.04), s * 0.07, skin_d)
	# face
	ci.draw_circle(c, s * 0.5, skin)

	# front hair
	if hat == 0:
		match style:
			1: _cap(ci, c, s, hair, 0.54, -0.2, 0.2)
			2: _cap(ci, c, s, Art.fade(hair, 0.85), 0.505, -0.3, 0.2)
			3: _cap(ci, c, s, hair, 0.54, -0.16, 0.22, 0.16)
			4:
				for k in 9:
					var a := PI + PI * float(k) / 8.0
					ci.draw_circle(_p(c, s, cos(a) * 0.5, sin(a) * 0.5 - 0.02), s * 0.13, hair)
			5: _cap(ci, c, s, hair, 0.54, -0.22, 0.16)
			6, 9: _cap(ci, c, s, hair, 0.54, -0.18, 0.26, 0.1)
			7, 8: _cap(ci, c, s, hair, 0.54, -0.2, 0.2)
			10: _cap(ci, c, s, Art.fade(hair, 0.55), 0.505, -0.34, 0.2)

	# beard
	var bcol := hair if age < 2 or look["haircol"] != 0 else Color(HAIRS[5])
	match int(look["beard"]):
		1:
			_poly(ci, c, s, _jaw(0.5, 0.14), Art.fade(bcol, 0.35))
		2:
			_poly(ci, c, s, _jaw(0.53, 0.12), bcol)
		3:
			_poly(ci, c, s, _jaw(0.56, 0.1), bcol)
		4:
			_poly(ci, c, s, [[-0.1, 0.3], [0.0, 0.42], [0.1, 0.3], [0.06, 0.2], [-0.06, 0.2]], bcol)
		6:
			_poly(ci, c, s, _jaw(0.55, 0.06), bcol)
			_poly(ci, c, s, [[-0.38, 0.3], [-0.1, 0.9], [0.1, 0.9], [0.38, 0.3]], bcol)
	# nose, mouth
	ci.draw_arc(_p(c, s, 0.0, 0.07), s * 0.06, 0.4, PI - 0.4, 8, skin_d, lw, true)
	var mouth := ink
	if int(look["beard"]) in [2, 3, 6]:
		_poly(ci, c, s, [[-0.12, 0.2], [0.12, 0.2], [0.1, 0.28], [-0.1, 0.28]], skin.darkened(0.05))
	if gender == 0:
		mouth = Color("D9455A")
	ci.draw_arc(_p(c, s, 0.0, 0.14), s * 0.15, 0.3, PI - 0.3, 12, mouth, lw * (1.4 if gender == 0 else 1.0), true)
	if int(look["beard"]) in [4, 5, 3, 2, 6]:
		_poly(ci, c, s, [[-0.2, 0.12], [-0.02, 0.1], [0.0, 0.13], [0.02, 0.1], [0.2, 0.12], [0.16, 0.17], [0.0, 0.14], [-0.16, 0.17]], bcol)

	# eyes, brows
	var er := s * (0.06 if age == 0 else 0.05)
	for sx in [-1.0, 1.0]:
		var ec := _p(c, s, 0.17 * sx, 0.0)
		ci.draw_circle(ec, er, ink)
		ci.draw_circle(ec + Vector2(-er * 0.3, -er * 0.3), er * 0.3, Color.WHITE)
		if gender == 0:
			ci.draw_line(ec + Vector2(sx * er * 0.9, -er * 0.7), ec + Vector2(sx * er * 1.9, -er * 1.5), ink, lw * 0.8, true)
		var bw := lw * (1.5 if gender == 1 else 1.0)
		var browc := hair if age < 2 else Color(HAIRS[5])
		ci.draw_line(_p(c, s, 0.17 * sx - 0.07, -0.1), _p(c, s, 0.17 * sx + 0.07, -0.11 - 0.015 * sx), browc, bw, true)
	if age == 2:
		for sx in [-1.0, 1.0]:
			ci.draw_line(_p(c, s, 0.3 * sx, -0.02), _p(c, s, 0.36 * sx, -0.05), skin_d, lw * 0.7, true)
			ci.draw_line(_p(c, s, 0.3 * sx, 0.02), _p(c, s, 0.36 * sx, 0.04), skin_d, lw * 0.7, true)
			ci.draw_line(_p(c, s, 0.1 * sx, 0.1), _p(c, s, 0.14 * sx, 0.2), skin_d, lw * 0.6, true)
		if hat == 0 and style in [0, 10]:
			ci.draw_line(_p(c, s, -0.18, -0.26), _p(c, s, 0.18, -0.26), skin_d, lw * 0.7, true)
	if gender == 0:
		ci.draw_circle(_p(c, s, -0.3, 0.12), s * 0.06, Art.fade(Color("FF8FA0"), 0.35))
		ci.draw_circle(_p(c, s, 0.3, 0.12), s * 0.06, Art.fade(Color("FF8FA0"), 0.35))

	# glasses
	var gcol := Color("2B2B35")
	match int(look["glasses"]):
		1:
			for sx in [-1.0, 1.0]:
				ci.draw_arc(_p(c, s, 0.19 * sx, 0.0), s * 0.13, 0.0, TAU, 24, gcol, lw, true)
			ci.draw_line(_p(c, s, -0.06, 0.0), _p(c, s, 0.06, 0.0), gcol, lw, true)
		2:
			for sx in [-1.0, 1.0]:
				Art.rrect(ci, Rect2(_p(c, s, 0.19 * sx - 0.14, -0.09), Vector2(0.28, 0.2) * s), Palette.CLEAR, s * 0.04, gcol, int(maxf(2.0, lw)))
			ci.draw_line(_p(c, s, -0.05, -0.02), _p(c, s, 0.05, -0.02), gcol, lw, true)
		3:
			for sx in [-1.0, 1.0]:
				Art.rrect(ci, Rect2(_p(c, s, 0.19 * sx - 0.15, -0.09), Vector2(0.3, 0.2) * s), Art.fade(gcol, 0.92), s * 0.07)
			ci.draw_line(_p(c, s, -0.05, -0.03), _p(c, s, 0.05, -0.03), gcol, lw * 1.4, true)
		4:
			for sx in [-1.0, 1.0]:
				ci.draw_circle(_p(c, s, 0.19 * sx, 0.01), s * 0.14, Art.fade(Color("F2C14E"), 0.25))
				ci.draw_arc(_p(c, s, 0.19 * sx, 0.01), s * 0.14, 0.0, TAU, 24, Color("F2C14E"), lw, true)
			ci.draw_line(_p(c, s, -0.05, -0.04), _p(c, s, 0.05, -0.04), Color("F2C14E"), lw, true)

	# headwear
	match hat:
		1:
			var cc := Palette.CORAL if look["shirt"] != 1 else Palette.TEAL
			var pts := PackedVector2Array()
			for k in 25:
				var a := PI + PI * float(k) / 24.0
				pts.append(_p(c, s, cos(a) * 0.55, sin(a) * 0.55 - 0.02))
			ci.draw_colored_polygon(pts, cc)
			Art.rrect(ci, Rect2(_p(c, s, -0.1, -0.2), Vector2(0.68, 0.08) * s), cc.darkened(0.2), s * 0.04)
		2:
			var cc2 := Palette.AMBER
			var pts2 := PackedVector2Array()
			for k in 25:
				var a2 := PI + PI * float(k) / 24.0
				pts2.append(_p(c, s, cos(a2) * 0.54, sin(a2) * 0.62 - 0.1))
			ci.draw_colored_polygon(pts2, cc2)
			Art.rrect(ci, Rect2(_p(c, s, -0.56, -0.2), Vector2(1.12, 0.12) * s), cc2.darkened(0.15), s * 0.05)
			ci.draw_circle(_p(c, s, 0, -0.72), s * 0.07, cc2.lightened(0.2))
		3:
			var sc := Color("8E6BD6")
			var ring := PackedVector2Array()
			for k in 41:
				var a3 := PI * 0.85 + (TAU - PI * 0.7) * float(k) / 40.0
				ring.append(_p(c, s, cos(a3) * 0.62, sin(a3) * 0.62))
			ci.draw_polyline(ring, sc, s * 0.2, true)
			var cap := PackedVector2Array()
			for k in 25:
				var a4 := PI + PI * float(k) / 24.0
				cap.append(_p(c, s, cos(a4) * 0.6, sin(a4) * 0.6 - 0.04))
			cap.append(_p(c, s, 0.5, -0.22))
			cap.append(_p(c, s, -0.5, -0.22))
			ci.draw_colored_polygon(cap, sc)
			ci.draw_arc(_p(c, s, 0, 0.0), s * 0.5, PI * 0.15, PI * 0.85, 20, sc, s * 0.16, true)

	# the ham touch: headset
	if int(look["headset"]) == 1:
		ci.draw_arc(c, s * 0.6, PI + 0.25, TAU - 0.25, 28, Palette.AMBER, maxf(3.0, s * 0.06), true)
		Art.rrect(ci, Rect2(c.x - s * 0.64, c.y - s * 0.1, s * 0.16, s * 0.34), Palette.AMBER, s * 0.06)
		Art.rrect(ci, Rect2(c.x + s * 0.48, c.y - s * 0.1, s * 0.16, s * 0.34), Palette.AMBER, s * 0.06)


## Lower-face polygon for beards: outer jaw arc plus an inner edge at height `inner_y`.
static func _jaw(radius: float, inner_y: float) -> Array:
	var pts: Array = []
	for k in 21:
		var a := deg_to_rad(10.0 + 160.0 * float(k) / 20.0)
		pts.append([cos(a) * radius, sin(a) * radius])
	pts.append([-0.36, inner_y])
	pts.append([-0.18, inner_y + 0.06])
	pts.append([0.18, inner_y + 0.06])
	pts.append([0.36, inner_y])
	return pts
