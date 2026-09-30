class_name Art
extends RefCounted
## Vector drawing helpers. Everything in the game is drawn with these, so there are no
## image assets to manage. All functions draw onto a CanvasItem inside its _draw().

const SKINS := [Color("E6B08A"), Color("C98F62"), Color("8D5A3C"), Color("F2C9A5"), Color("B37A50"), Color("6E4630")]
const HAIRS := [Palette.WOOD, Palette.INK, Palette.AMBER_DEEP, Palette.CORAL, Palette.TEAL, Palette.MUTED]
const SHIRTS := [Palette.TEAL, Palette.CORAL, Palette.GREEN, Palette.AMBER, Palette.WOOD, Palette.MUTED]

static var _boxes: Dictionary = {}


static func fade(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, c.a * a)


static func rrect(ci: CanvasItem, r: Rect2, color: Color, radius: float = 12.0, border: Color = Palette.CLEAR, bw: int = 0) -> void:
	var key := "%s|%d|%s|%d" % [color.to_html(true), int(radius), border.to_html(true), bw]
	var sb: StyleBoxFlat = _boxes.get(key, null)
	if sb == null:
		sb = StyleBoxFlat.new()
		sb.bg_color = color
		sb.set_corner_radius_all(int(radius))
		sb.anti_aliasing = true
		if bw > 0:
			sb.border_color = border
			sb.set_border_width_all(bw)
		_boxes[key] = sb
	ci.draw_style_box(sb, r)


static func ring(ci: CanvasItem, c: Vector2, radius: float, color: Color, width: float = 3.0) -> void:
	ci.draw_arc(c, radius, 0.0, TAU, 64, color, width, true)


static func rings(ci: CanvasItem, c: Vector2, t: float, count: int, max_r: float, color: Color = Palette.TEAL, width: float = 3.0) -> void:
	for i in count:
		var f := fposmod(t * 0.3 + float(i) / float(count), 1.0)
		ring(ci, c, 24.0 + f * max_r, fade(color, (1.0 - f) * 0.65), width)


static func stars(ci: CanvasItem, rect: Rect2, count: int, t: float, seed_value: int = 7) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var p := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		var r := rng.randf_range(1.0, 2.6)
		var tw := 0.5 + 0.5 * sin(t * rng.randf_range(0.6, 2.2) + rng.randf() * TAU)
		ci.draw_circle(p, r, fade(Palette.CREAM, 0.25 + 0.6 * tw))


static func sparkle(ci: CanvasItem, c: Vector2, size: float, color: Color, rot: float = 0.0) -> void:
	var pts := PackedVector2Array()
	for k in 8:
		var a := rot + float(k) * PI / 4.0
		var rad := size if k % 2 == 0 else size * 0.3
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	ci.draw_colored_polygon(pts, color)


static func dashed_rect(ci: CanvasItem, r: Rect2, color: Color, width: float = 2.0, dash: float = 8.0) -> void:
	var a := r.position
	var b := Vector2(r.end.x, r.position.y)
	var c := r.end
	var d := Vector2(r.position.x, r.end.y)
	ci.draw_dashed_line(a, b, color, width, dash)
	ci.draw_dashed_line(b, c, color, width, dash)
	ci.draw_dashed_line(c, d, color, width, dash)
	ci.draw_dashed_line(d, a, color, width, dash)


## Head centre `c`, head diameter `s`.
static func avatar(ci: CanvasItem, c: Vector2, s: float, idx: int) -> void:
	var i := posmod(idx, 6)
	var skin: Color = SKINS[i]
	var hair: Color = HAIRS[i]
	var shirt: Color = SHIRTS[i]
	rrect(ci, Rect2(c.x - s * 0.7, c.y + s * 0.42, s * 1.4, s * 0.85), shirt, s * 0.35)
	ci.draw_circle(c, s * 0.5, skin)
	var pts := PackedVector2Array()
	for k in 21:
		var a := PI + PI * float(k) / 20.0
		pts.append(c + Vector2(cos(a), sin(a)) * s * 0.52)
	ci.draw_colored_polygon(pts, hair)
	match i % 3:
		1:
			rrect(ci, Rect2(c.x - s * 0.52, c.y - s * 0.08, s * 0.2, s * 0.5), hair, s * 0.1)
			rrect(ci, Rect2(c.x + s * 0.32, c.y - s * 0.08, s * 0.2, s * 0.5), hair, s * 0.1)
		2:
			ci.draw_circle(c + Vector2(0, -s * 0.56), s * 0.16, hair)
	ci.draw_circle(c + Vector2(-s * 0.17, s * 0.02), s * 0.05, Palette.INK)
	ci.draw_circle(c + Vector2(s * 0.17, s * 0.02), s * 0.05, Palette.INK)
	ci.draw_arc(c + Vector2(0, s * 0.1), s * 0.16, 0.3, PI - 0.3, 12, Palette.INK, maxf(2.0, s * 0.03), true)
	ci.draw_arc(c, s * 0.6, PI + 0.25, TAU - 0.25, 28, Palette.AMBER, maxf(3.0, s * 0.06), true)
	rrect(ci, Rect2(c.x - s * 0.64, c.y - s * 0.1, s * 0.16, s * 0.34), Palette.AMBER, s * 0.06)
	rrect(ci, Rect2(c.x + s * 0.48, c.y - s * 0.1, s * 0.16, s * 0.34), Palette.AMBER, s * 0.06)


## Draw one shack part inside rect `r`. `freq` is only used by the transceiver display.
static func gear(ci: CanvasItem, id: String, r: Rect2, alpha: float = 1.0, glow: float = 0.0, freq: String = "14.205") -> void:
	var o := r.position
	var w := r.size.x
	var h := r.size.y
	if glow > 0.0:
		ci.draw_circle(r.get_center(), maxf(w, h) * 0.75, fade(Palette.AMBER, 0.14 * glow))
	match id:
		"psu":
			rrect(ci, r, fade(Palette.PANEL2, alpha), 14, fade(Palette.LINE, alpha), 2)
			ci.draw_circle(o + Vector2(0.26 * w, 0.48 * h), 0.17 * minf(w, h), fade(Palette.AMBER, alpha))
			ci.draw_circle(o + Vector2(0.26 * w, 0.48 * h), 0.09 * minf(w, h), fade(Palette.AMBER_DEEP, alpha))
			rrect(ci, Rect2(o.x + 0.55 * w, o.y + 0.22 * h, 0.3 * w, 0.09 * h), fade(Palette.GREEN, alpha), 4)
			rrect(ci, Rect2(o.x + 0.55 * w, o.y + 0.42 * h, 0.3 * w, 0.07 * h), fade(Palette.LINE, alpha), 4)
			ci.draw_circle(o + Vector2(0.7 * w, 0.75 * h), 0.06 * minf(w, h), fade(Palette.CORAL, alpha))
		"speaker":
			rrect(ci, r, fade(Palette.PANEL2, alpha), 14, fade(Palette.LINE, alpha), 2)
			var cw := o + Vector2(0.5 * w, 0.64 * h)
			ci.draw_circle(cw, 0.34 * w, fade(Palette.INK, alpha))
			ring(ci, cw, 0.34 * w, fade(Palette.LINE, alpha), 3.0)
			ci.draw_circle(cw, 0.12 * w, fade(Palette.AMBER, alpha))
			var ct := o + Vector2(0.5 * w, 0.2 * h)
			ci.draw_circle(ct, 0.14 * w, fade(Palette.INK, alpha))
			ring(ci, ct, 0.14 * w, fade(Palette.LINE, alpha), 2.0)
		"transceiver":
			rrect(ci, r, fade(Palette.PANEL2, alpha), 16, fade(Palette.LINE, alpha), 2)
			rrect(ci, Rect2(o.x + 0.06 * w, o.y + 0.14 * h, 0.55 * w, 0.4 * h), fade(Palette.INK, alpha), 10)
			ci.draw_string(Style.font_mono, o + Vector2(0.09 * w, 0.44 * h), freq, HORIZONTAL_ALIGNMENT_LEFT, 0.5 * w, int(0.3 * h), fade(Palette.TEAL, alpha))
			ci.draw_circle(o + Vector2(0.82 * w, 0.4 * h), 0.19 * h, fade(Palette.AMBER, alpha))
			ci.draw_circle(o + Vector2(0.82 * w, 0.4 * h), 0.1 * h, fade(Palette.AMBER_DEEP, alpha))
			rrect(ci, Rect2(o.x + 0.06 * w, o.y + 0.68 * h, 0.23 * w, 0.09 * h), fade(Palette.LINE, alpha), 5)
			rrect(ci, Rect2(o.x + 0.33 * w, o.y + 0.68 * h, 0.23 * w, 0.09 * h), fade(Palette.LINE, alpha), 5)
			ci.draw_circle(o + Vector2(0.93 * w, 0.1 * h), 0.04 * h, fade(Palette.GREEN, alpha))
		"mic":
			rrect(ci, Rect2(o.x + 0.12 * w, o.y + 0.86 * h, 0.76 * w, 0.1 * h), fade(Palette.LINE, alpha), 6)
			rrect(ci, Rect2(o.x + 0.45 * w, o.y + 0.36 * h, 0.1 * w, 0.52 * h), fade(Palette.LINE, alpha), 3)
			var hc := o + Vector2(0.5 * w, 0.25 * h)
			ci.draw_circle(hc, 0.4 * w, fade(Palette.PANEL2, alpha))
			ring(ci, hc, 0.4 * w, fade(Palette.MUTED, alpha), 3.0)
			for k in 3:
				var yy := hc.y - 0.16 * h + float(k) * 0.16 * h
				ci.draw_line(Vector2(hc.x - 0.24 * w, yy), Vector2(hc.x + 0.24 * w, yy), fade(Palette.INK, alpha), 3.0)
			ci.draw_circle(o + Vector2(0.5 * w, 0.62 * h), 0.05 * w, fade(Palette.CORAL, alpha))
		"antenna":
			rrect(ci, Rect2(o.x + 0.47 * w, o.y + 0.16 * h, 0.06 * w, 0.84 * h), fade(Palette.LINE, alpha), 3)
			var arms := [[0.26, 0.9], [0.4, 0.7], [0.54, 0.55]]
			for a in arms:
				var aw: float = float(a[1]) * w
				rrect(ci, Rect2(o.x + 0.5 * w - aw / 2.0, o.y + float(a[0]) * h, aw, 0.03 * h), fade(Palette.AMBER, alpha), 4)
			ci.draw_circle(o + Vector2(0.5 * w, 0.12 * h), 0.08 * w, fade(Palette.AMBER, alpha))
		"swr":
			rrect(ci, r, fade(Palette.PANEL2, alpha), 14, fade(Palette.LINE, alpha), 2)
			rrect(ci, Rect2(o.x + 0.1 * w, o.y + 0.14 * h, 0.8 * w, 0.72 * h), fade(Palette.CREAM, alpha), 8)
			var pivot := o + Vector2(0.5 * w, 0.82 * h)
			ci.draw_arc(pivot, 0.45 * h, PI + 0.5, TAU - 0.5, 20, fade(Palette.INK, alpha), 2.0, true)
			ci.draw_line(pivot, pivot + Vector2(0.26 * w, -0.5 * h), fade(Palette.CORAL, alpha), 3.0, true)
			ci.draw_circle(pivot, 0.05 * h, fade(Palette.INK, alpha))
		"key":
			rrect(ci, Rect2(o.x + 0.05 * w, o.y + 0.55 * h, 0.9 * w, 0.4 * h), fade(Palette.WOOD.darkened(0.25), alpha), 10, fade(Palette.AMBER_DEEP, alpha), 2)
			rrect(ci, Rect2(o.x + 0.14 * w, o.y + 0.3 * h, 0.66 * w, 0.14 * h), fade(Palette.LINE, alpha), 6)
			ci.draw_circle(o + Vector2(0.2 * w, 0.24 * h), 0.13 * h, fade(Palette.AMBER, alpha))
			ci.draw_circle(o + Vector2(0.8 * w, 0.42 * h), 0.07 * h, fade(Palette.MUTED, alpha))
		"logbook":
			rrect(ci, Rect2(o.x + 0.04 * w, o.y + 0.12 * h, 0.62 * w, 0.8 * h), fade(Palette.PANEL2, alpha), 8, fade(Palette.AMBER, alpha), 2)
			rrect(ci, Rect2(o.x + 0.1 * w, o.y + 0.2 * h, 0.5 * w, 0.64 * h), fade(Palette.CREAM, alpha), 4)
			for k in 4:
				var ly := o.y + (0.32 + 0.14 * float(k)) * h
				ci.draw_line(Vector2(o.x + 0.14 * w, ly), Vector2(o.x + 0.56 * w, ly), fade(Palette.MUTED, alpha), 2.0)
			ci.draw_line(o + Vector2(0.72 * w, 0.82 * h), o + Vector2(0.94 * w, 0.24 * h), fade(Palette.AMBER, alpha), 6.0, true)
			ci.draw_line(o + Vector2(0.72 * w, 0.82 * h), o + Vector2(0.7 * w, 0.9 * h), fade(Palette.CORAL, alpha), 6.0, true)
		_:
			rrect(ci, r, fade(Palette.PANEL2, alpha), 12)
