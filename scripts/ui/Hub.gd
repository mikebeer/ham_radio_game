extends Screen
## 4. The radio shack: goals on the left, the shack on the right. Empty slots fill up as
## you earn parts.

const SLOTS := {
	"antenna": Rect2(1090, 60, 150, 230),
	"psu": Rect2(350, 370, 120, 100),
	"speaker": Rect2(490, 340, 110, 130),
	"transceiver": Rect2(640, 350, 260, 120),
	"mic": Rect2(930, 330, 90, 140),
	"swr": Rect2(350, 520, 120, 80),
	"key": Rect2(700, 520, 150, 70),
	"logbook": Rect2(880, 520, 150, 70),
}
const GOAL_COLORS := [Palette.TEAL, Palette.AMBER, Palette.GREEN, Palette.CORAL]

var _t := 0.0
var _room: Control
var _gear: Dictionary = {}
var _pending_award := ""


func _build() -> void:
	add_bg()
	_gear.clear()
	_room = Control.new()
	_room.set_anchors_preset(Control.PRESET_FULL_RECT)
	_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.draw.connect(_draw_room)
	add_child(_room)
	_build_slots()
	_build_sidebar()
	_build_topbar()
	_first_show()


func _process(delta: float) -> void:
	_t += delta
	if _room:
		_room.queue_redraw()


# ---- room -------------------------------------------------------------------------------

func _draw_room() -> void:
	var ci := _room
	ci.draw_rect(Rect2(320, 0, 960, 470), Palette.PANEL)
	ci.draw_rect(Rect2(320, 470, 960, 250), Palette.WOOD)
	ci.draw_rect(Rect2(320, 470, 960, 10), Palette.AMBER_DEEP)
	ci.draw_rect(Rect2(320, 480, 960, 240), Palette.fade_ink(0.25))
	# window with night sky
	Art.rrect(ci, Rect2(560, 50, 260, 190), Palette.INK, 18, Palette.LINE, 3)
	Art.stars(ci, Rect2(575, 65, 230, 160), 14, _t, 21)
	ci.draw_circle(Vector2(758, 100), 18, Art.fade(Palette.CREAM, 0.9))
	ci.draw_rect(Rect2(688, 52, 4, 186), Palette.LINE)
	ci.draw_rect(Rect2(562, 143, 256, 4), Palette.LINE)
	# wall decorations earned by goals
	if Game.rules_done(1):
		Art.rrect(ci, Rect2(350, 80, 150, 110), Palette.CREAM, 6, Palette.AMBER_DEEP, 4)
		for i in 4:
			ci.draw_line(Vector2(368, 108 + i * 16), Vector2(482 - (i % 2) * 30, 108 + i * 16), Palette.MUTED, 2.0)
		ci.draw_circle(Vector2(468, 166), 12, Palette.AMBER)
	if bool(FactDatabase.get_fact("qso.done", false)):
		Art.rrect(ci, Rect2(860, 110, 130, 90), Palette.TEAL, 6, Palette.CREAM, 4)
		ci.draw_string(Style.font_mono, Vector2(872, 152), Game.callsign(), HORIZONTAL_ALIGNMENT_LEFT, 110, 20, Palette.INK)
		ci.draw_string(Style.font_mono, Vector2(872, 182), "QSL 73", HORIZONTAL_ALIGNMENT_LEFT, 110, 16, Palette.INK)
	# on the air: signal rings around the antenna
	if Game.tier("antenna") > 0 and Game.tier("transceiver") > 0:
		Art.rings(ci, Vector2(1165, 76), _t, 3, 100.0, Palette.TEAL, 2.0)


func _build_slots() -> void:
	for id in Game.PART_IDS:
		var r: Rect2 = SLOTS[id]
		var g := GearView.new()
		g.part_id = id
		g.owned = Game.tier(id) > 0
		g.tier = Game.tier(id)
		g.need_upgrade = Game.tier(id) > 0 and Game.tier(id) < Game.cur_level()
		g.position = r.position
		g.size = r.size
		g.pressed.connect(_on_slot)
		add_child(g)
		_gear[id] = g
		add_lbl(I18n.t("part." + id), Vector2(r.position.x - 10, r.end.y + 6), r.size.x + 20, 12,
				Palette.CREAM if g.owned else Palette.MUTED, Style.font_body_bold, HORIZONTAL_ALIGNMENT_CENTER)


func _on_slot(id: String) -> void:
	Sfx.click()
	if Game.tier(id) < Game.cur_level():
		SceneManager.go("build", {"part": id})
		return
	_gear[id].wiggle()
	match id:
		"transceiver":
			Sfx.play_morse("CQ DE " + Game.callsign(), 14.0)
		"key":
			Sfx.play_morse("73", 14.0)
		_:
			toast(I18n.t("hub.owned"), Palette.TEAL)


# ---- sidebar ----------------------------------------------------------------------------

func _build_sidebar() -> void:
	var bg := ColorRect.new()
	bg.color = Palette.PANEL
	bg.size = Vector2(320, 720)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var edge := ColorRect.new()
	edge.color = Palette.LINE
	edge.position = Vector2(319, 0)
	edge.size = Vector2(1, 720)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(edge)

	add_art("avatar", Rect2(8, 6, 100, 110), 0, "", Game.look())
	add_title(str(Game.profile.get("name", "")), Vector2(112, 22), 26, Palette.CREAM, 196)
	var cs := I18n.t("hub.callsign", [Game.callsign()]) if Game.has_callsign() else I18n.t("hub.callsign_pending")
	add_lbl(cs, Vector2(112, 60), 200, 14, Palette.MUTED, Style.font_mono)
	var pb := Button.new()
	pb.position = Vector2(4, 4)
	pb.size = Vector2(312, 118)
	pb.flat = true
	pb.focus_mode = Control.FOCUS_NONE
	pb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pb.pressed.connect(func() -> void: SceneManager.go("settings"))
	add_child(pb)
	add_lbl(I18n.t("hub.goals"), Vector2(24, 132), 0, 14, Palette.MUTED, Style.font_body_bold)

	var lvl := Game.level_data()
	var lessons_total := (lvl.get("lessons", []) as Array).size()
	var lessons_done := Game.fact_int(Game.k("rules.lessons_done"))
	var quiz_ok := int(bool(FactDatabase.get_fact(Game.k("rules.quiz_passed"), false)))
	var extra := 2 if Game.cur_level() == 1 else 1
	var g1_total := lessons_total + extra
	var g1_done := mini(lessons_done, lessons_total) + quiz_ok + (int(Game.has_callsign()) if extra == 2 else 0)
	var g1 := 1.0 if Game.rules_done() else float(g1_done) / float(g1_total)
	var qso_ready := Game.qso_ready()
	var steps := Game.qso_steps_done()
	var passed := Game.morse_passed()
	var cap := Game.morse_cap()
	var goals := [
		{"prog": g1, "sub": I18n.t("hub.goal1.sub", [I18n.t("country." + Game.country()), I18n.loc(lvl.get("licence", ""))]),
		 "status": I18n.t("hub.goal1.prog", [g1_total if Game.rules_done() else g1_done, g1_total]), "cb": _goal_rules},
		{"prog": float(Game.parts_owned()) / 8.0, "sub": I18n.t("hub.goal2.sub"),
		 "status": I18n.t("hub.goal2.prog", [Game.parts_owned(), 8]), "cb": _goal_shack},
		{"prog": float(steps) / float(Game.QSO_STEPS), "sub": I18n.t("hub.goal3.sub"),
		 "status": I18n.t("common.locked") if (not qso_ready and steps == 0) else I18n.t("hub.goal3.prog", [steps, Game.QSO_STEPS]), "cb": _goal_qso},
		{"prog": float(mini(passed, cap)) / float(cap), "sub": I18n.t("hub.goal4.sub"),
		 "status": I18n.t("hub.goal4.prog", [mini(passed + 1, cap), cap]), "cb": _goal_morse},
	]
	for i in 4:
		var y := 156 + i * 128
		var g: Dictionary = goals[i]
		var locked: bool = (i == 2 and not qso_ready and steps == 0)
		var card := Button.new()
		card.position = Vector2(20, y)
		card.size = Vector2(280, 116)
		card.custom_minimum_size = Vector2(280, 116)
		card.focus_mode = Control.FOCUS_NONE
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.add_theme_stylebox_override("normal", Style.box(Palette.PANEL2, 20, Palette.LINE, 1))
		card.add_theme_stylebox_override("hover", Style.box(Palette.LINE, 20, Palette.MUTED, 1))
		card.add_theme_stylebox_override("pressed", Style.box(Palette.PANEL, 20, Palette.AMBER, 2))
		card.pressed.connect(g["cb"])
		add_child(card)
		var col: Color = GOAL_COLORS[i]
		var badge := Panel.new()
		badge.position = Vector2(36, y + 14)
		badge.size = Vector2(36, 36)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_stylebox_override("panel", Style.box(Art.fade(col, 0.35 if locked else 1.0), 18))
		add_child(badge)
		add_lbl(str(i + 1), Vector2(36, y + 18), 36, 20, Palette.INK, Style.font_display, HORIZONTAL_ALIGNMENT_CENTER)
		add_lbl(I18n.t("hub.goal%d" % (i + 1)), Vector2(84, y + 10), 208, 19, Palette.MUTED if locked else Palette.CREAM, Style.font_display)
		add_lbl(g["sub"], Vector2(84, y + 38), 208, 12, Palette.MUTED)
		var track := Panel.new()
		track.position = Vector2(36, y + 80)
		track.size = Vector2(248, 10)
		track.mouse_filter = Control.MOUSE_FILTER_IGNORE
		track.add_theme_stylebox_override("panel", Style.box(Palette.INK, 5, Palette.CLEAR, 0, Vector2(0, 0)))
		add_child(track)
		var fill_w := 248.0 * clampf(float(g["prog"]), 0.0, 1.0)
		if fill_w > 0.0:
			var fill := Panel.new()
			fill.position = Vector2(36, y + 80)
			fill.size = Vector2(maxf(fill_w, 10.0), 10)
			fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fill.add_theme_stylebox_override("panel", Style.box(col, 5, Palette.CLEAR, 0, Vector2(0, 0)))
			add_child(fill)
		add_lbl(g["status"], Vector2(36, y + 94), 248, 12, Palette.MUTED, Style.font_body_bold)


func _goal_rules() -> void:
	if Game.cur_level() == 1 and bool(FactDatabase.get_fact("rules.quiz_passed", false)) and not Game.has_callsign():
		SceneManager.go("callsign")
	else:
		SceneManager.go("legal")


func _goal_shack() -> void:
	toast(I18n.t("hub.click_slot"), Palette.AMBER)
	for id in Game.PART_IDS:
		if Game.tier(id) < Game.cur_level():
			_gear[id].wiggle()


func _goal_qso() -> void:
	if Game.qso_ready():
		SceneManager.go("qso")
	else:
		toast(I18n.t("hub.tip_locked"), Palette.CORAL)


func _goal_morse() -> void:
	SceneManager.go("morse")


# ---- top bar ----------------------------------------------------------------------------

func _build_topbar() -> void:
	# level chips: one per class level of this country
	var x := 330.0
	for n in range(1, Game.MAX_LEVELS + 1):
		var exists := n <= Game.level_count()
		var open := exists and n <= Game.levels_unlocked()
		var text := "%d · %s" % [n, I18n.loc(Game.level_data(n).get("short", ""))] if exists else "%d · —" % n
		var b := _toggle_chip(text, Vector2(x, 14), Vector2(96, 40), n == Game.cur_level())
		b.disabled = not open
		if not exists:
			b.tooltip_text = I18n.t("level.soon")
		elif not open:
			b.tooltip_text = I18n.t("level.locked")
		else:
			b.tooltip_text = I18n.loc(Game.level_data(n).get("licence", ""))
			b.pressed.connect(func() -> void:
				Game.set_level(n)
				_rebuild())
		x += 102.0
	var chip := add_card(Rect2(650, 14, 200, 40), Style.box(Palette.PANEL2, 20, Palette.LINE, 1))
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dot := Panel.new()
	dot.position = Vector2(662, 22)
	dot.size = Vector2(24, 24)
	dot.add_theme_stylebox_override("panel", Style.box(Palette.AMBER, 12))
	add_child(dot)
	add_lbl(I18n.t("hub.shack", [Game.parts_owned(), 8]), Vector2(694, 20), 0, 20, Palette.AMBER, Style.font_display)
	var lib := add_btn(I18n.t("hub.library"), Vector2(862, 14), func() -> void: SceneManager.go("library"), "", Vector2(112, 40))
	lib.add_theme_font_size_override("font_size", 16)
	var spl := add_btn(I18n.t("hub.spelling"), Vector2(982, 14), func() -> void: SceneManager.go("spell"), "", Vector2(112, 40))
	spl.add_theme_font_size_override("font_size", 16)
	add_top_icons(10.0)


func _toggle_chip(text: String, pos: Vector2, sz: Vector2, on: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.custom_minimum_size = sz
	b.size = sz
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_stylebox_override("normal", Style.box(Palette.AMBER if on else Palette.PANEL2, 20, Palette.CLEAR if on else Palette.LINE, 0 if on else 1, Vector2(8, 6)))
	b.add_theme_stylebox_override("hover", Style.box(Palette.AMBER if on else Palette.LINE, 20, Palette.CLEAR, 0, Vector2(8, 6)))
	b.add_theme_stylebox_override("pressed", Style.box(Palette.AMBER, 20, Palette.CLEAR, 0, Vector2(8, 6)))
	b.add_theme_stylebox_override("disabled", Style.box(Palette.fade_ink(0.4), 20, Palette.LINE, 1, Vector2(8, 6)))
	b.add_theme_color_override("font_color", Palette.INK if on else Palette.CREAM)
	b.add_theme_color_override("font_hover_color", Palette.INK if on else Palette.CREAM)
	b.add_theme_color_override("font_disabled_color", Art.fade(Palette.MUTED, 0.6))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(Sfx.click)
	add_child(b)
	return b


# ---- level up ---------------------------------------------------------------------------

func _show_levelup(n: int) -> void:
	Sfx.reward()
	var ov := Control.new()
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ov)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.add_child(dim)
	var art := Control.new()
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.draw.connect(func() -> void:
		Art.rrect(art, Rect2(340, 130, 600, 460), Palette.PANEL, 28, Palette.AMBER, 3)
		Art.rings(art, Vector2(640, 232), _t, 3, 110.0, Palette.AMBER)
		for i in 8:
			var a := _t * 0.6 + float(i) * TAU / 8.0
			Art.sparkle(art, Vector2(640, 232) + Vector2(cos(a), sin(a)) * 130.0, 9.0 + 3.0 * sin(_t * 3.0 + i), Palette.AMBER, _t)
		Art.avatar(art, Vector2(640, 232), 64.0, Game.look()))
	ov.add_child(art)
	var t1 := Style.display_label(I18n.t("level.up", [n]), 40, Palette.AMBER)
	t1.position = Vector2(340, 352)
	t1.size = Vector2(600, 50)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(t1)
	var t2 := Style.display_label(I18n.loc(Game.level_data(n).get("licence", "")), 26, Palette.CREAM)
	t2.position = Vector2(340, 404)
	t2.size = Vector2(600, 40)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(t2)
	var t3 := Style.label(I18n.t("level.up_body"), 17, Palette.MUTED)
	t3.position = Vector2(380, 450)
	t3.size = Vector2(520, 80)
	t3.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov.add_child(t3)
	var b := Button.new()
	b.text = I18n.t("common.continue")
	b.theme_type_variation = "PrimaryButton"
	b.position = Vector2(540, 526)
	b.custom_minimum_size = Vector2(200, 48)
	b.pressed.connect(func() -> void:
		ov.queue_free()
		_rebuild())
	ov.add_child(b)


# ---- arrival effects --------------------------------------------------------------------

func _first_show() -> void:
	var p: Dictionary = SceneManager.params
	SceneManager.params = {}
	if p.has("awarded"):
		var id: String = p["awarded"]
		if _gear.has(id):
			_gear[id].owned = false
			await get_tree().create_timer(0.5).timeout
			if is_instance_valid(_gear[id]):
				_gear[id].pop()
				Sfx.reward()
				toast(I18n.t("part." + id) + " +1", Palette.AMBER)
	elif p.has("goal"):
		Sfx.reward()
		toast(I18n.t("hub.goal%d" % (Game.QUEST_IDS.find(p["goal"]) + 1)), Palette.GREEN)
	var up := Game.check_level_up()
	if up > 0:
		await get_tree().create_timer(1.6 if p.has("goal") else 0.4).timeout
		if is_inside_tree():
			_show_levelup(up)
