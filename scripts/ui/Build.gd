extends Screen
## 6. Goal 2: learn about one shack part, pass its quiz, and it appears in your shack.

const PASS_COUNT := 3
const GEAR_SIZES := {
	"psu": Vector2(240, 200), "speaker": Vector2(220, 260), "transceiver": Vector2(420, 190),
	"mic": Vector2(180, 290), "antenna": Vector2(230, 370), "swr": Vector2(250, 160),
	"key": Vector2(320, 150), "logbook": Vector2(320, 150),
}

var _part := ""
var _data: Dictionary
var _state := "lesson"      # lesson, quiz, reward, failed
var _t := 0.0
var _scene: Control
var _pop := 0.0             # 0..1 reward animation progress
var _score := 0
var _page := 0


func _ready() -> void:
	_part = str(SceneManager.params.get("part", "psu"))
	_data = Content.part_tier(_part, Game.cur_level())
	if Game.owns(_part):
		_state = "lesson"
	super._ready()


func _build() -> void:
	add_bg()
	var part_name := I18n.t("part." + _part)
	add_header(I18n.t("build.title"), I18n.t("build.lesson_sub", [part_name]) + " · " + I18n.t("level.name", [Game.cur_level()]) if _state == "lesson" else part_name)
	add_card(Rect2(60, 120, 560, 500))
	_scene = Control.new()
	_scene.position = Vector2(60, 120)
	_scene.size = Vector2(560, 500)
	_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene.draw.connect(_draw_scene)
	add_child(_scene)
	add_card(Rect2(660, 120, 560, 500))
	match _state:
		"lesson":
			_build_lesson(part_name)
		"quiz":
			_build_quiz()
		"reward":
			_build_reward(part_name)
		"failed":
			_build_failed()


func _process(delta: float) -> void:
	_t += delta
	if _scene:
		_scene.queue_redraw()


func _draw_scene() -> void:
	var ci := _scene
	Art.stars(ci, Rect2(20, 20, 520, 260), 22, _t, 3)
	var earned := Game.owns(_part)
	var pop := 1.0 if _state != "reward" else clampf(_pop, 0.0, 1.0)
	if _state == "reward":
		ci.draw_circle(Vector2(280, 300), 190.0 * pop, Art.fade(Palette.AMBER, 0.12))
		Art.rings(ci, Vector2(280, 300), _t * 1.4, 3, 240.0 * pop, Palette.TEAL)
	# floor
	ci.draw_rect(Rect2(0, 400, 560, 100), Palette.WOOD)
	ci.draw_rect(Rect2(0, 400, 560, 8), Palette.AMBER_DEEP)
	var sz: Vector2 = GEAR_SIZES.get(_part, Vector2(240, 200))
	var scale_f := 0.35 + 0.65 * pop if _state == "reward" else 1.0
	var s := sz * scale_f
	var bottom := 420.0 if _part != "antenna" else 490.0
	var r := Rect2(Vector2(280.0 - s.x / 2.0, bottom - s.y - (0.0 if _state != "reward" else (1.0 - pop) * 40.0)), s)
	Art.gear(ci, _part, r, 1.0 if (earned or _state != "lesson") else 0.85, 0.0)
	if _state == "reward":
		for i in 6:
			var a := _t * 0.8 + float(i) * TAU / 6.0
			var d := 150.0 + 20.0 * sin(_t * 3.0 + i)
			Art.sparkle(ci, Vector2(280, 250) + Vector2(cos(a), sin(a)) * d, 10.0 + 4.0 * sin(_t * 4.0 + i), Palette.AMBER, _t)


# ---- states -----------------------------------------------------------------------------

func _cards() -> Array:
	var cards: Array = _data.get("cards", [])
	if cards.is_empty():
		cards = [{"t": I18n.t("part." + _part), "b": _data.get("lesson", "")}]
	return cards


func _read_key() -> String:
	return Game.k("shack.%s.read" % _part)


func _build_lesson(part_name: String) -> void:
	var cards := _cards()
	var n := cards.size()
	_page = clampi(_page, 0, n - 1)
	add_lbl("%s  ·  %d / %d" % [part_name, _page + 1, n], Vector2(692, 140), 496, 15, Palette.AMBER, Style.font_body_bold)
	var view := LessonView.new()
	view.position = Vector2(692, 172)
	add_child(view)
	view.show_card(cards[_page], Vector2(496, 344), 17)
	for i in n:
		var d := Panel.new()
		d.position = Vector2(692 + i * 22, 524)
		d.size = Vector2(14, 14)
		d.add_theme_stylebox_override("panel", Style.box(Palette.TEAL if i <= _page else Palette.LINE, 7))
		add_child(d)
	var last := _page == n - 1
	if last:
		Game.set_flag(_read_key(), true)
	if _page > 0:
		add_btn(I18n.t("common.back"), Vector2(692, 556), func() -> void:
			_page -= 1
			_rebuild(), "", Vector2(110, 44))
	if last:
		add_btn(I18n.t("build.start_quiz"), Vector2(920, 556), func() -> void:
			_state = "quiz"
			_rebuild(), "PrimaryButton", Vector2(268, 44))
	else:
		add_btn(I18n.t("common.next"), Vector2(1018, 556), func() -> void:
			Game.stat_add("cards")
			_page += 1
			_rebuild(), "PrimaryButton", Vector2(170, 44))
		if Game.fact_bool(_read_key()):
			add_btn(I18n.t("build.skip_to_quiz"), Vector2(820, 556), func() -> void:
				_state = "quiz"
				_rebuild(), "", Vector2(190, 44))


func _build_quiz() -> void:
	var quiz := Quiz.new()
	quiz.position = Vector2(692, 146)
	add_child(quiz)
	quiz.start(Quiz.prepare(_data.get("questions", [])), 496.0)
	quiz.finished.connect(_on_quiz_done)


func _on_quiz_done(correct: int, total: int) -> void:
	_score = correct
	if correct >= PASS_COUNT:
		var already := Game.owns(_part)
		if not already:
			Game.stat_add("quizzes")
			Game.award(_part)
			Sfx.reward()
		_state = "reward"
		_pop = 0.0
		create_tween().tween_property(self, "_pop", 1.0, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		Sfx.bad()
		_state = "failed"
	_rebuild()


func _build_reward(part_name: String) -> void:
	add_lbl(I18n.t("build.unlocked"), Vector2(692, 146), 0, 14, Palette.AMBER, Style.font_body_bold)
	add_title(part_name, Vector2(692, 174), 44, Palette.CREAM, 500)
	add_lbl(I18n.t("common.score", [_score, 4]), Vector2(692, 246), 496, 20, Palette.GREEN, Style.font_display)
	var row := add_card(Rect2(692, 320, 496, 84), Style.box(Palette.PANEL2, 18, Palette.LINE, 1))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_lbl(I18n.t("build.shack_count"), Vector2(712, 330), 0, 14, Palette.MUTED, Style.font_body_bold)
	for i in Game.PART_IDS.size():
		var d := Panel.new()
		d.position = Vector2(712 + i * 46, 360)
		d.size = Vector2(30, 30)
		d.add_theme_stylebox_override("panel", Style.box(Palette.AMBER if Game.owns(Game.PART_IDS[i]) else Palette.LINE, 15))
		add_child(d)
	add_lbl("%d / 8" % Game.parts_owned(), Vector2(1080, 334), 90, 22, Palette.AMBER, Style.font_display, HORIZONTAL_ALIGNMENT_RIGHT)
	var next_id := ""
	for id in Game.PART_IDS:
		if not Game.owns(id):
			next_id = id
			break
	if next_id != "":
		add_lbl(I18n.t("build.next_part", [I18n.t("part." + next_id)]), Vector2(692, 430), 496, 18, Palette.CREAM, Style.font_body_bold)
	else:
		add_lbl(I18n.t("build.all_done"), Vector2(692, 430), 496, 20, Palette.GREEN, Style.font_display)
	add_btn(I18n.t("build.back"), Vector2(880, 540), func() -> void:
		SceneManager.go("hub", {"awarded": _part}), "PrimaryButton", Vector2(308, 52))


func _build_failed() -> void:
	add_title(I18n.t("common.score", [_score, 4]), Vector2(692, 150), 40, Palette.CORAL, 496)
	add_lbl(I18n.t("build.failed", [PASS_COUNT, 4]), Vector2(692, 220), 496, 22, Palette.CREAM, Style.font_body_bold)
	add_btn(I18n.t("common.retry"), Vector2(692, 400), func() -> void:
		_state = "quiz"
		_rebuild(), "PrimaryButton", Vector2(200, 52))
	add_btn(I18n.t("legal.review"), Vector2(912, 400), func() -> void:
		_state = "lesson"
		_rebuild(), "", Vector2(200, 52))
