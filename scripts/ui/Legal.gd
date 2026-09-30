extends Screen
## 5. Goal 1: the rules of your country. Read the lessons, then take the quiz.

const PASS_RATIO := 0.7
const QUIZ_LENGTH := 10

var _pack: Dictionary
var _lvl: Dictionary
var _step := 0                   # 0..n-1 lessons, n = quiz
var _quiz: Quiz
var _result: Dictionary = {}


func _build() -> void:
	_pack = Game.pack()
	_lvl = Game.level_data()
	add_bg()
	var lessons: Array = _lvl.get("lessons", [])
	var n := lessons.size()
	var country_name := "%s · %s" % [I18n.t("country." + Game.country()), I18n.loc(_lvl.get("class", ""))]
	var sub := I18n.t("legal.sub", [country_name, mini(_step + 1, n), n]) if _step < n else I18n.t("legal.quiz_sub", [country_name])
	add_header(I18n.t("legal.title"), sub)

	add_card(Rect2(60, 120, 500, 500))
	add_card(Rect2(600, 120, 620, 500))
	_build_outline(lessons, n)
	if _step < n:
		_build_lesson(lessons[_step], n)
	else:
		_build_quiz_panel()


# ---- lesson card (right) ----------------------------------------------------------------

func _build_lesson(lesson: Dictionary, n: int) -> void:
	var view := LessonView.new()
	view.position = Vector2(632, 146)
	add_child(view)
	view.show_card(lesson, Vector2(556, 360), 17)
	var src := I18n.loc(_pack.get("source", ""))
	if _pack.get("status", "") == "primer":
		src = I18n.t("legal.primer") + ". " + src
	else:
		src = I18n.t("legal.official") + ": " + src
		if I18n.locale == "en":
			src += ". " + I18n.t("legal.translation")
	add_lbl(src, Vector2(92, 594), 440, 10, Palette.MUTED)
	var last := (_step == n - 1)
	var nb := add_btn(I18n.t("legal.start_quiz") if last else I18n.t("common.next"), Vector2(1030, 556), _next_lesson, "PrimaryButton", Vector2(160, 44))
	nb.position.x = 1188.0 - nb.size.x
	if _step > 0:
		add_btn(I18n.t("common.back"), Vector2(632, 556), func() -> void:
			_step -= 1
			_rebuild(), "", Vector2(110, 44))
	if not last and Game.fact_bool(Game.k("rules.lessons_all")):
		add_btn(I18n.t("legal.skip_to_quiz"), Vector2(820, 556), func() -> void:
			_step = n
			_start_quiz()
			_rebuild(), "", Vector2(190, 44))


func _next_lesson() -> void:
	var n := (_lvl.get("lessons", []) as Array).size()
	Game.set_flag(Game.k("rules.lessons_done"), maxi(Game.fact_int(Game.k("rules.lessons_done")), _step + 1))
	_step += 1
	if _step >= n:
		Game.set_flag(Game.k("rules.lessons_all"), true)
		_start_quiz()
	_rebuild()


# ---- outline (left) ---------------------------------------------------------------------

func _build_outline(lessons: Array, n: int) -> void:
	add_title(I18n.loc(_lvl.get("licence", "")), Vector2(92, 140), 24, Palette.AMBER, 440)
	add_lbl(I18n.t("country." + Game.country()), Vector2(92, 176), 0, 15, Palette.MUTED)
	var row := 30 if n > 10 else (34 if n > 8 else 44)
	var y0 := 204
	for i in n + 1:
		var y := y0 + i * row
		var done := i < _step or Game.fact_int(Game.k("rules.lessons_done")) > i
		var cur := i == _step
		var dot := Panel.new()
		dot.position = Vector2(92, y)
		dot.size = Vector2(26, 26)
		dot.add_theme_stylebox_override("panel", Style.box(Palette.GREEN if done else (Palette.AMBER if cur else Palette.LINE), 13))
		add_child(dot)
		var label := str(i + 1) if i < n else "?"
		add_lbl(label, Vector2(92, y + 1), 26, 14, Palette.INK, Style.font_display, HORIZONTAL_ALIGNMENT_CENTER)
		var txt := I18n.loc(lessons[i]["t"]) if i < n else I18n.t("legal.start_quiz") + "  (%d)" % _quiz_size()
		add_lbl(txt, Vector2(130, y + 2), 410, 16, Palette.CREAM if (i <= _step) else Palette.MUTED, Style.font_body_bold)


# ---- quiz (right) -----------------------------------------------------------------------

func _quiz_size() -> int:
	return mini(QUIZ_LENGTH, (_lvl.get("questions", []) as Array).size())


func _start_quiz() -> void:
	_result = {}


func _build_quiz_panel() -> void:
	if not _result.is_empty():
		_build_result()
		return
	_quiz = Quiz.new()
	_quiz.position = Vector2(632, 146)
	add_child(_quiz)
	_quiz.start(Quiz.prepare(_lvl.get("questions", []), _quiz_size()), 556.0)
	_quiz.finished.connect(_on_finished)


func _on_finished(correct: int, total: int) -> void:
	_result = {"correct": correct, "total": total, "need": ceili(total * PASS_RATIO)}
	if correct >= int(_result["need"]):
		Game.set_flag(Game.k("rules.quiz_passed"), true)
		Game.set_flag(Game.k("rules.lessons_done"), (_lvl.get("lessons", []) as Array).size())
		Game.set_flag(Game.k("rules.lessons_all"), true)
		Sfx.reward()
	_rebuild()


func _build_result() -> void:
	var ok: bool = int(_result["correct"]) >= int(_result["need"])
	var col := Palette.GREEN if ok else Palette.CORAL
	add_title(I18n.t("common.score", [_result["correct"], _result["total"]]), Vector2(632, 150), 40, col, 556)
	var msg := I18n.t("legal.passed", [I18n.t("country." + Game.country())]) if ok else I18n.t("legal.failed", [_result["need"]])
	add_lbl(msg, Vector2(632, 220), 556, 22, Palette.CREAM, Style.font_body_bold)
	if ok:
		if Game.has_callsign() or Game.cur_level() > 1:
			add_btn(I18n.t("build.back"), Vector2(632, 400), func() -> void:
				SceneManager.go("hub", {"goal": "rules"}), "PrimaryButton", Vector2(240, 52))
		else:
			add_btn(I18n.t("callsign.find"), Vector2(632, 400), func() -> void: SceneManager.go("callsign"), "PrimaryButton", Vector2(280, 52))
	else:
		add_btn(I18n.t("common.retry"), Vector2(632, 400), func() -> void:
			_result = {}
			_rebuild(), "PrimaryButton", Vector2(200, 52))
		add_btn(I18n.t("legal.review"), Vector2(852, 400), func() -> void:
			_result = {}
			_step = 0
			_rebuild(), "", Vector2(200, 52))
