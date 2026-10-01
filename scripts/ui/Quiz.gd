class_name Quiz
extends Control
## Multiple-choice quiz. Give it questions from Quiz.prepare(); it emits finished(correct, total).

signal answered(correct: bool)
signal finished(correct: int, total: int)

var _qs: Array = []
var _i := 0
var _correct := 0
var _box: VBoxContainer
var _head: Label
var _question: Label
var _options: Array[Button] = []
var _feedback: Label
var _next: Button
var _locked := false


## Turns raw {"q","a","c"} data into localised, shuffled questions.
static func prepare(raw: Array, count: int = 0) -> Array:
	var pool := raw.duplicate()
	pool.shuffle()
	if count > 0 and pool.size() > count:
		pool = pool.slice(0, count)
	var out: Array = []
	for r in pool:
		var order: Array = range(r["a"].size())
		order.shuffle()
		var opts: Array = []
		var correct := 0
		for k in order.size():
			opts.append(I18n.loc(r["a"][order[k]]))
			if int(order[k]) == int(r["c"]):
				correct = k
		out.append({"q": I18n.loc(r["q"]), "a": opts, "c": correct})
	return out


func start(qs: Array, width: float, head_key: String = "legal.question") -> void:
	_qs = qs
	_i = 0
	_correct = 0
	for c in get_children():
		c.queue_free()
	_options.clear()
	custom_minimum_size.x = width
	size.x = width
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	_box.custom_minimum_size.x = width
	_box.size.x = width
	add_child(_box)

	_head = Style.label("", 13, Palette.TEAL, Style.font_body_bold)
	_box.add_child(_head)
	_question = Style.display_label("", 25)
	_question.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question.custom_minimum_size = Vector2(width, 96)
	_box.add_child(_question)
	for k in 4:
		var b := Button.new()
		b.theme_type_variation = "ChoiceButton"
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(width, 56)
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.pressed.connect(_on_option.bind(k))
		_box.add_child(b)
		_options.append(b)
	var row := HBoxContainer.new()
	row.custom_minimum_size.x = width
	_box.add_child(row)
	_feedback = Style.label("", 18, Palette.GREEN, Style.font_display)
	_feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(_feedback)
	_next = Button.new()
	_next.theme_type_variation = "PrimaryButton"
	_next.focus_mode = Control.FOCUS_NONE
	_next.pressed.connect(_on_next)
	row.add_child(_next)
	_show()


func _show() -> void:
	_locked = false
	var q: Dictionary = _qs[_i]
	_head.text = I18n.t("legal.question", [_i + 1, _qs.size()])
	_question.text = q["q"]
	var letters := ["A", "B", "C", "D"]
	for k in 4:
		var b := _options[k]
		b.text = "%s    %s" % [letters[k], q["a"][k]]
		b.disabled = false
		b.remove_theme_stylebox_override("disabled")
		b.remove_theme_color_override("font_disabled_color")
	_feedback.text = ""
	_next.text = I18n.t("common.next") if _i < _qs.size() - 1 else I18n.t("common.continue")
	_next.visible = false


func _on_option(k: int) -> void:
	if _locked:
		return
	_locked = true
	var q: Dictionary = _qs[_i]
	var ok: bool = (k == int(q["c"]))
	if ok:
		_correct += 1
		Sfx.good()
		_feedback.text = I18n.t("common.correct")
		_feedback.add_theme_color_override("font_color", Palette.GREEN)
	else:
		Sfx.bad()
		_feedback.text = I18n.t("common.wrong")
		_feedback.add_theme_color_override("font_color", Palette.CORAL)
	for j in 4:
		_options[j].disabled = true
	_mark(_options[int(q["c"])], Palette.GREEN)
	if not ok:
		_mark(_options[k], Palette.CORAL)
	_next.visible = true
	Game.stat_add("answers")
	if ok:
		Game.stat_add("correct")
	answered.emit(ok)


func _mark(b: Button, col: Color) -> void:
	b.add_theme_stylebox_override("disabled", Style.box(Color(col.r, col.g, col.b, 0.22), 16, col, 3, Vector2(18, 14)))


func _on_next() -> void:
	Sfx.click()
	if _i < _qs.size() - 1:
		_i += 1
		_show()
	else:
		if _correct == _qs.size() and _qs.size() >= 3:
			Game.stat_add("perfect")
		finished.emit(_correct, _qs.size())
