extends Screen
## Settings: profile, statistics, badges, language, game (sound, new game), about and licences.

const TABS := ["profile", "stats", "badges", "language", "game", "about"]

var _tab := "profile"
var _reset_armed := false
var _t := 0.0
var _medals: Control


func _ready() -> void:
	_tab = str(SceneManager.params.get("tab", "profile"))
	super._ready()


func _process(delta: float) -> void:
	_t += delta
	if _medals:
		_medals.queue_redraw()


func _build() -> void:
	add_bg()
	_medals = null
	add_icon("back", Vector2(40, 28), func() -> void: SceneManager.go("hub"), I18n.t("common.back"))
	add_icon("share", Vector2(1168, 28), Share.open, I18n.t("share.btn"))
	add_title(I18n.t("settings.title"), Vector2(116, 26), 32)
	add_lbl(str(Game.profile.get("name", "")), Vector2(116, 70), 700, 16, Palette.MUTED)
	for i in TABS.size():
		var id: String = TABS[i]
		var on := id == _tab
		var b := Button.new()
		b.text = I18n.t("settings." + (id if id != "profile" else "profile"))
		b.toggle_mode = false
		b.position = Vector2(60, 124 + i * 58)
		b.custom_minimum_size = Vector2(250, 48)
		b.size = Vector2(250, 48)
		b.focus_mode = Control.FOCUS_NONE
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 18)
		b.add_theme_stylebox_override("normal", Style.box(Palette.AMBER if on else Palette.PANEL2, 16, Palette.CLEAR if on else Palette.LINE, 0 if on else 1, Vector2(18, 8)))
		b.add_theme_stylebox_override("hover", Style.box(Palette.AMBER if on else Palette.LINE, 16, Palette.CLEAR, 0, Vector2(18, 8)))
		b.add_theme_stylebox_override("pressed", Style.box(Palette.AMBER, 16, Palette.CLEAR, 0, Vector2(18, 8)))
		b.add_theme_color_override("font_color", Palette.INK if on else Palette.CREAM)
		b.add_theme_color_override("font_hover_color", Palette.INK if on else Palette.CREAM)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.pressed.connect(func() -> void:
			Sfx.click()
			_tab = id
			_reset_armed = false
			_rebuild())
		add_child(b)
	add_card(Rect2(340, 120, 880, 500))
	match _tab:
		"profile": _tab_profile()
		"stats": _tab_stats()
		"badges": _tab_badges()
		"language": _tab_language()
		"game": _tab_game()
		"about": _tab_about()


# ---- tabs -------------------------------------------------------------------------------

func _tab_profile() -> void:
	add_art("avatar", Rect2(370, 150, 270, 300), 0, "", Game.look())
	var lvl := Game.level_data()
	add_title(str(Game.profile.get("name", "")), Vector2(670, 160), 40, Palette.CREAM, 520)
	var has := Game.has_callsign()
	add_lbl(Game.callsign() if has else I18n.t("profile.none"), Vector2(670, 220), 520, 28, Palette.AMBER if has else Palette.MUTED, Style.font_mono)
	add_lbl(I18n.t("country." + Game.country()), Vector2(670, 272), 520, 20, Palette.TEAL, Style.font_body_bold)
	add_lbl(I18n.t("level.name", [Game.cur_level()]) + " · " + I18n.loc(lvl.get("licence", "")), Vector2(670, 306), 520, 17, Palette.CREAM)
	var since := str(Game.profile.get("since", ""))
	if since != "":
		add_lbl(I18n.t("settings.since", [since]), Vector2(670, 340), 520, 15, Palette.MUTED)
	add_btn(I18n.t("settings.edit_profile"), Vector2(670, 400), func() -> void: SceneManager.go("setup", {"profile": true}), "PrimaryButton", Vector2(380, 50))
	if bool(FactDatabase.get_fact("rules.quiz_passed", false)):
		add_btn(I18n.t("profile.change_call"), Vector2(670, 466), func() -> void: SceneManager.go("callsign"), "", Vector2(260, 44))


func _tab_stats() -> void:
	var lv_n := Game.level_count()
	var qso_total := 0
	for l in range(1, Game.MAX_LEVELS + 1):
		qso_total += Game.qso_steps_done(l)
	var answers := Game.stat("answers")
	var acc := "–" if answers == 0 else "%d %%" % roundi(100.0 * float(Game.stat("correct")) / float(answers))
	var tiles := [
		["stat.level", "%d / %d" % [Game.cur_level(), lv_n], Palette.AMBER],
		["stat.parts", "%d / %d" % [Game.total_parts(), lv_n * Game.PART_IDS.size()], Palette.TEAL],
		["stat.lessons", str(Game.stat("cards")), Palette.GREEN],
		["stat.answers", str(answers), Palette.CREAM],
		["stat.accuracy", acc, Palette.GREEN],
		["stat.quizzes", str(Game.stat("quizzes")), Palette.AMBER],
		["stat.qso", "%d / %d" % [qso_total, lv_n * Game.QSO_STEPS], Palette.CORAL],
		["stat.morse", "%d / %d" % [Game.morse_passed(), Game.MORSE_LEVELS], Palette.TEAL],
		["stat.badges", "%d / %d" % [Game.badges_earned(), Game.BADGE_IDS.size()], Palette.AMBER],
	]
	for i in tiles.size():
		var x := 366.0 + (i % 3) * 282.0
		var y := 148.0 + (i / 3) * 148.0
		add_card(Rect2(x, y, 266, 130), Style.box(Palette.PANEL2, 20, Palette.LINE, 1))
		add_title(tiles[i][1], Vector2(x + 20, y + 18), 40, tiles[i][2], 230)
		add_lbl(I18n.t(tiles[i][0]), Vector2(x + 20, y + 84), 230, 15, Palette.MUTED, Style.font_body_bold)
	var wpm := Game.fact_int("morse.wpm", 0)
	if wpm > 0:
		add_lbl("%s: %d WPM" % [I18n.t("stat.wpm"), wpm], Vector2(366, 590), 500, 14, Palette.MUTED)


func _tab_badges() -> void:
	_medals = Control.new()
	_medals.position = Vector2.ZERO
	_medals.size = Vector2(1280, 720)
	_medals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_medals.draw.connect(_draw_medals)
	add_child(_medals)
	for i in Game.BADGE_IDS.size():
		var id: String = Game.BADGE_IDS[i]
		var x := 358.0 + (i % 5) * 170.0
		var y := 140.0 + (i / 5) * 160.0
		var got := Game.badge_earned(id)
		add_lbl(I18n.t("badge.%s.t" % id), Vector2(x, y + 84), 160, 15, Palette.CREAM if got else Palette.MUTED, Style.font_body_bold, HORIZONTAL_ALIGNMENT_CENTER)
		add_lbl(I18n.t("badge.%s.d" % id), Vector2(x, y + 106), 160, 11, Palette.MUTED, null, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_medals() -> void:
	for i in Game.BADGE_IDS.size():
		var id: String = Game.BADGE_IDS[i]
		var c := Vector2(358.0 + (i % 5) * 170.0 + 80.0, 140.0 + (i / 5) * 160.0 + 38.0)
		var got := Game.badge_earned(id)
		var col: Color = [Palette.AMBER, Palette.TEAL, Palette.GREEN, Palette.CORAL][i % 4]
		if not got:
			col = Palette.LINE
		_medals.draw_circle(c, 40.0, Art.fade(col, 0.25))
		_medals.draw_circle(c, 32.0, col)
		_medals.draw_arc(c, 36.0, 0.0, TAU, 40, Palette.CREAM if got else Palette.MUTED, 2.0, true)
		if got:
			Art.sparkle(_medals, c, 18.0 + 2.0 * sin(_t * 2.0 + i), Palette.INK, _t * 0.3)
		else:
			Art.rrect(_medals, Rect2(c + Vector2(-9, -2), Vector2(18, 15)), Palette.MUTED, 3)
			_medals.draw_arc(c + Vector2(0, -3), 7.0, PI, TAU, 12, Palette.MUTED, 3.0, true)


func _tab_language() -> void:
	for i in I18n.LOCALES.size():
		var loc: String = I18n.LOCALES[i]
		var on: bool = loc == I18n.locale
		var b := Button.new()
		b.text = I18n.NAMES[loc]
		b.position = Vector2(370 + (i % 3) * 270, 150 + (i / 3) * 84)
		b.custom_minimum_size = Vector2(250, 64)
		b.size = Vector2(250, 64)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 22)
		b.add_theme_stylebox_override("normal", Style.box(Palette.AMBER if on else Palette.PANEL2, 18, Palette.CLEAR if on else Palette.LINE, 0 if on else 1, Vector2(12, 8)))
		b.add_theme_stylebox_override("hover", Style.box(Palette.AMBER if on else Palette.LINE, 18, Palette.CLEAR, 0, Vector2(12, 8)))
		b.add_theme_color_override("font_color", Palette.INK if on else Palette.CREAM)
		b.add_theme_color_override("font_hover_color", Palette.INK if on else Palette.CREAM)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.pressed.connect(func() -> void:
			Sfx.click()
			I18n.set_locale(loc)
			Game.profile["locale"] = loc
			Game.save_game())
		add_child(b)
		if I18n.UNREVIEWED.has(loc):
			add_lbl("AI", Vector2(370 + (i % 3) * 270 + 214, 150 + (i / 3) * 84 + 4), 0, 11, Palette.INK if on else Palette.MUTED, Style.font_body_bold)
	add_lbl(I18n.t("settings.lang_content"), Vector2(370, 340), 800, 17, Palette.CREAM)
	add_lbl(I18n.t("settings.lang_note"), Vector2(370, 410), 800, 15, Palette.MUTED)


func _tab_game() -> void:
	add_btn(I18n.t("profile.sound_on") if Sfx.enabled else I18n.t("profile.sound_off"), Vector2(370, 150), func() -> void:
		Sfx.enabled = not Sfx.enabled
		Game.set_flag("audio.sfx_off", not Sfx.enabled)
		_rebuild(), "", Vector2(260, 50))
	add_btn(I18n.t("audio.voice_on") if Voice.enabled else I18n.t("audio.voice_off"), Vector2(660, 150), func() -> void:
		Voice.set_enabled(not Voice.enabled)
		_rebuild(), "", Vector2(260, 50))
	add_btn(I18n.t("audio.radio_on") if Voice.radio else I18n.t("audio.radio_off"), Vector2(660, 216), func() -> void:
		Voice.set_radio(not Voice.radio)
		_rebuild(), "", Vector2(260, 50))
	add_btn(I18n.t("settings.library"), Vector2(370, 216), func() -> void: SceneManager.go("library"), "", Vector2(260, 50))
	add_btn(I18n.t("share.btn"), Vector2(370, 282), Share.open, "", Vector2(260, 50))
	add_lbl(I18n.t("settings.reset_text"), Vector2(370, 400), 760, 16, Palette.MUTED)
	add_btn(I18n.t("hub.reset_sure") if _reset_armed else I18n.t("hub.reset"), Vector2(370, 456), func() -> void:
		if not _reset_armed:
			_reset_armed = true
			_rebuild()
			return
		Game.reset_all()
		SceneManager.go("splash"), "", Vector2(260, 50))


func _tab_about() -> void:
	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.text = I18n.t("about.body")
	body.position = Vector2(370, 144)
	body.size = Vector2(820, 450)
	body.add_theme_font_override("normal_font", Style.font_body)
	body.add_theme_font_size_override("normal_font_size", 16)
	body.add_theme_color_override("default_color", Palette.MUTED)
	body.meta_clicked.connect(func(m) -> void: OS.shell_open(str(m)))
	add_child(body)
