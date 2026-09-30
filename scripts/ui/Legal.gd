extends Screen
## 5. Goal 1: the rules of your country. Read the lessons, then take the quiz.

const PASS_RATIO := 0.7
const QUIZ_LENGTH := 10

var _pack: Dictionary
var _step := 0                   # 0..n-1 lessons, n = quiz
var _quiz: Quiz
var _result: Dictionary = {}
var _art: Control
var _t := 0.0


func _build() -> void:
	_pack = Game.pack()
	add_bg()
	var lessons: Array = _pack.get("lessons", [])
	var n := lessons.size()
	var country_name := I18n.t("country." + Game.country())
	var sub := I18n.t("legal.sub", [country_name, mini(_step + 1, n), n]) if _step < n else I18n.t("legal.quiz_sub", [country_name])
	add_header(I18n.t("legal.title"), sub)

	for i in n + 1:
		var d := Panel.new()
		d.position = Vector2(1220 - (n + 1 - i) * 32, 40)
		d.size = Vector2(20, 20)
		var on := i < _step or (_step >= n and i == n)
		d.add_theme_stylebox_override("panel", Style.box(Palette.TEAL if on else Palette.LINE, 10))
		add_child(d)

	add_card(Rect2(60, 120, 540, 500))
	add_card(Rect2(640, 120, 580, 500))
	if _step < n:
		_build_lesson(lessons[_step], n)
		_build_outline(lessons, n)
	else:
		_build_lesson(lessons[n - 1], n)
		_build_quiz_panel()


func _process(delta: float) -> void:
	_t += delta
	if _art:
		_art.queue_redraw()


# ---- lesson card (left) -----------------------------------------------------------------

func _build_lesson(lesson: Dictionary, n: int) -> void:
	var idx := mini(_step, n - 1)
	add_title(I18n.loc(lesson["t"]), Vector2(92, 146), 30, Palette.CREAM, 476)
	add_lbl(I18n.loc(lesson["b"]), Vector2(92, 200), 476, 18, Palette.MUTED)
	_art = Control.new()
	_art.position = Vector2(92, 388)
	_art.size = Vector2(476, 120)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.draw.connect(_draw_lesson_art.bind(idx))
	add_child(_art)
	var src := I18n.loc(_pack.get("source", ""))
	if _pack.get("status", "") == "primer":
		src = I18n.t("legal.primer") + "\n" + src
	else:
		src = I18n.t("legal.official") + ": " + src
		if I18n.locale == "en":
			src += ". " + I18n.t("legal.translation")
	add_lbl(src, Vector2(92, 512), 300, 11, Palette.MUTED)
	if _step < n:
		var last := (_step == n - 1)
		add_btn(I18n.t("legal.start_quiz") if last else I18n.t("common.next"), Vector2(400, 560), _next_lesson, "PrimaryButton", Vector2(170, 44))
		if _step > 0:
			var pb := add_btn(I18n.t("common.back"), Vector2(92, 560), func() -> void:
				_step -= 1
				_rebuild(), "", Vector2(110, 44))


func _draw_lesson_art(idx: int) -> void:
	var ci := _art
	var c := Vector2(238, 62)
	match idx:
		0:
			Art.rings(ci, Vector2(238, 60), _t, 3, 56.0, Palette.TEAL)
			Art.gear(ci, "antenna", Rect2(203, 4, 70, 120))
		1:
			Art.rrect(ci, Rect2(158, 6, 160, 118), Palette.CREAM, 8, Palette.AMBER_DEEP, 4)
			for i in 4:
				ci.draw_line(Vector2(176, 34 + i * 18), Vector2(300 - (i % 2) * 34, 34 + i * 18), Palette.MUTED, 2.0)
			ci.draw_circle(Vector2(290, 104), 14, Palette.AMBER)
		2:
			Art.rrect(ci, Rect2(88, 12, 300, 106), Palette.AMBER, 20)
			Art.rrect(ci, Rect2(98, 22, 280, 86), Palette.INK, 14)
			ci.draw_string(Style.font_mono, Vector2(112, 82), Game.callsign(), HORIZONTAL_ALIGNMENT_LEFT, 260, 48, Palette.AMBER)
		3:
			ci.draw_arc(c + Vector2(0, 4), 50, 0.0, TAU, 48, Palette.CORAL, 8.0, true)
			ci.draw_line(c + Vector2(-35, 39), c + Vector2(35, -31), Palette.CORAL, 8.0, true)
			Art.gear(ci, "logbook", Rect2(208, 34, 60, 56), 0.5)
		_:
			Art.avatar(ci, Vector2(190, 46), 60.0, 0)
			Art.avatar(ci, Vector2(290, 46), 60.0, 2)
			Art.rrect(ci, Rect2(206, 92, 68, 30), Palette.AMBER, 12)
			ci.draw_string(Style.font_mono, Vector2(216, 114), "/T", HORIZONTAL_ALIGNMENT_LEFT, 60, 22, Palette.INK)


func _next_lesson() -> void:
	var n := (_pack.get("lessons", []) as Array).size()
	Game.set_flag("rules.lessons_done", maxi(Game.fact_int("rules.lessons_done"), _step + 1))
	_step += 1
	if _step >= n:
		_start_quiz()
	_rebuild()


# ---- outline (right, while reading) -----------------------------------------------------

func _build_outline(lessons: Array, n: int) -> void:
	add_title(I18n.loc(_pack.get("licence", "")), Vector2(672, 146), 26, Palette.AMBER, 516)
	add_lbl(I18n.t("country." + Game.country()), Vector2(672, 186), 0, 16, Palette.MUTED)
	for i in n:
		var y := 240 + i * 56
		var done := i < _step or Game.fact_int("rules.lessons_done") > i
		var dot := Panel.new()
		dot.position = Vector2(672, y)
		dot.size = Vector2(32, 32)
		dot.add_theme_stylebox_override("panel", Style.box(Palette.GREEN if done else (Palette.AMBER if i == _step else Palette.LINE), 16))
		add_child(dot)
		add_lbl(str(i + 1), Vector2(672, y + 4), 32, 16, Palette.INK, Style.font_display, HORIZONTAL_ALIGNMENT_CENTER)
		add_lbl(I18n.loc(lessons[i]["t"]), Vector2(720, y + 2), 470, 20, Palette.CREAM if i <= _step else Palette.MUTED, Style.font_body_bold)
	add_lbl(I18n.t("legal.start_quiz") + "  (%d)" % _quiz_size(), Vector2(720, 240 + n * 56 + 2), 470, 20, Palette.MUTED, Style.font_body_bold)


# ---- quiz (right) -----------------------------------------------------------------------

func _quiz_size() -> int:
	return mini(QUIZ_LENGTH, (_pack.get("questions", []) as Array).size())


func _start_quiz() -> void:
	_result = {}


func _build_quiz_panel() -> void:
	if not _result.is_empty():
		_build_result()
		return
	_quiz = Quiz.new()
	_quiz.position = Vector2(672, 146)
	add_child(_quiz)
	_quiz.start(Quiz.prepare(_pack.get("questions", []), _quiz_size()), 516.0)
	_quiz.finished.connect(_on_finished)


func _on_finished(correct: int, total: int) -> void:
	_result = {"correct": correct, "total": total, "need": ceili(total * PASS_RATIO)}
	if correct >= int(_result["need"]):
		Game.set_flag("rules.quiz_passed", true)
		Game.set_flag("rules.lessons_done", (_pack.get("lessons", []) as Array).size())
		Sfx.reward()
	_rebuild()


func _build_result() -> void:
	var ok: bool = int(_result["correct"]) >= int(_result["need"])
	var col := Palette.GREEN if ok else Palette.CORAL
	add_title(I18n.t("common.score", [_result["correct"], _result["total"]]), Vector2(672, 150), 40, col, 516)
	var msg := I18n.t("legal.passed", [I18n.t("country." + Game.country())]) if ok else I18n.t("legal.failed", [_result["need"]])
	add_lbl(msg, Vector2(672, 220), 516, 22, Palette.CREAM, Style.font_body_bold)
	if ok:
		add_btn(I18n.t("build.back"), Vector2(672, 400), func() -> void:
			SceneManager.go("hub", {"goal": "rules"}), "PrimaryButton", Vector2(240, 52))
	else:
		add_btn(I18n.t("common.retry"), Vector2(672, 400), func() -> void:
			_result = {}
			_rebuild(), "PrimaryButton", Vector2(200, 52))
		add_btn(I18n.t("legal.review"), Vector2(892, 400), func() -> void:
			_result = {}
			_step = 0
			_rebuild(), "", Vector2(200, 52))
