extends Screen
## Spelling trainer: the NATO phonetic alphabet (the only alphabet used in amateur radio).
## Six words: spell your name, a place and a callsign, then decode three spelled words.

const LETTERS := {
	"A": "Alfa", "B": "Bravo", "C": "Charlie", "D": "Delta", "E": "Echo", "F": "Foxtrot", "G": "Golf", "H": "Hotel",
	"I": "India", "J": "Juliett", "K": "Kilo", "L": "Lima", "M": "Mike", "N": "November", "O": "Oscar", "P": "Papa",
	"Q": "Quebec", "R": "Romeo", "S": "Sierra", "T": "Tango", "U": "Uniform", "V": "Victor", "W": "Whiskey",
	"X": "X-ray", "Y": "Yankee", "Z": "Zulu",
}
## Also accepted when typing (lower case).
const ALIASES := {"alpha": "A", "juliet": "J", "whisky": "W", "xray": "X", "x-ray": "X", "x": "X"}
const DIGIT_WORDS := {"0": ["zero", "null"], "1": ["one", "eins"], "2": ["two", "zwei"], "3": ["three", "drei"], "4": ["four", "vier"],
	"5": ["five", "fuenf", "funf"], "6": ["six", "sechs"], "7": ["seven", "sieben"], "8": ["eight", "acht"], "9": ["nine", "niner", "neun"]}
const FOLD := {"Ä": "A", "Ö": "O", "Ü": "U", "ß": "SS", "É": "E", "È": "E", "Ê": "E", "À": "A", "Â": "A", "Ç": "C", "Ñ": "N",
	"Á": "A", "Í": "I", "Ó": "O", "Ú": "U", "Î": "I", "Ô": "O", "Û": "U", "Ø": "O", "Å": "A", "Æ": "AE"}
const ROUNDS := 6
const PASS := 5

var _state := "intro"            # intro, ask, feedback, result
var _tasks: Array = []
var _i := 0
var _score := 0
var _hint := false
var _chart := false
var _typed := ""
var _fb_ok := false
var _edit: LineEdit
var _hint_lbl: Label
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	super._ready()


func _build() -> void:
	add_bg()
	add_header(I18n.t("spell.title"), I18n.t("spell.sub"))
	add_card(Rect2(60, 120, 440, 500))
	add_card(Rect2(520, 120, 700, 500))
	_build_left()
	match _state:
		"intro": _build_intro()
		"ask": _build_ask()
		"feedback": _build_feedback()
		"result": _build_result()


# ---- left card: alphabet chart or the speaking avatar -------------------------------------

func _build_left() -> void:
	if _state == "intro" or _chart:
		var keys := LETTERS.keys()
		for i in keys.size():
			var col := i / 13
			var row := i % 13
			var x := 90.0 + col * 200.0
			var y := 146.0 + row * 34.0
			add_lbl(keys[i], Vector2(x, y), 30, 20, Palette.AMBER, Style.font_display)
			add_lbl(LETTERS[keys[i]], Vector2(x + 34, y + 1), 150, 19, Palette.CREAM, Style.font_body_bold)
		add_lbl("0 1 2 3 4 5 6 7 8 9  =  zero, one, two ...", Vector2(90, 150 + 13 * 34), 380, 13, Palette.MUTED)
	else:
		add_art("avatar", Rect2(90, 160, 380, 300), 0, "", Game.look())
		add_btn(I18n.t("spell.chart"), Vector2(90, 520), func() -> void:
			_chart = true
			_typed = _edit.text if _edit else _typed
			_rebuild(), "", Vector2(380, 44))
	if _state != "intro" and _chart:
		add_btn(I18n.t("spell.chart_hide"), Vector2(90, 580), func() -> void:
			_chart = false
			_typed = _edit.text if _edit else _typed
			_rebuild(), "", Vector2(380, 30))


# ---- intro ------------------------------------------------------------------------------

func _build_intro() -> void:
	add_title(I18n.t("spell.title"), Vector2(556, 146), 40, Palette.AMBER, 640)
	add_lbl(I18n.t("spell.intro"), Vector2(556, 214), 628, 19, Palette.CREAM)
	var best := Game.fact_int("spell.best", 0)
	if best > 0:
		add_lbl(I18n.t("spell.best", [best, ROUNDS]), Vector2(556, 440), 600, 17, Palette.GREEN, Style.font_body_bold)
	add_btn(I18n.t("spell.start"), Vector2(556, 520), _start, "PrimaryButton", Vector2(220, 52))


func _start() -> void:
	_tasks = _make_tasks()
	_i = 0
	_score = 0
	_state = "ask"
	_begin_task()


func _begin_task() -> void:
	_hint = false
	_typed = ""
	_state = "ask"
	_rebuild()
	var t: Dictionary = _tasks[_i]
	if t["mode"] == "decode" and Voice.usable():
		_listen.call_deferred()


func _exit_tree() -> void:
	Voice.stop()


## Speaks the code words of the current word (the answer spelled in NATO words).
func _listen() -> void:
	if not is_inside_tree() or _i >= _tasks.size():
		return
	Voice.speak_text(str(_tasks[_i]["answer"]))


func _audio_only() -> bool:
	return Voice.usable() and Game.fact_bool("spell.audio_only")


# ---- tasks ------------------------------------------------------------------------------

static func fold(s: String) -> String:
	var out := ""
	for ch in s.to_upper():
		if FOLD.has(ch):
			out += FOLD[ch]
		elif (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9"):
			out += ch
	return out


func _make_tasks() -> Array:
	var sp: Dictionary = Content.spelling
	var cities: Array = (sp.get("cities", {}) as Dictionary).get(Game.country(), ["Bern"]).duplicate()
	cities.shuffle()
	var words: Array = (sp.get("words", ["RADIO"]) as Array).duplicate()
	words.shuffle()
	var nm := fold(str(Game.profile.get("name", "")).split(" ")[0])
	if nm.length() < 2:
		nm = "ALEX"
	var cs := Game.callsign() if Game.has_callsign() else _fake_callsign()
	return [
		_task("encode", "name", str(Game.profile.get("name", nm)).split(" ")[0], nm),
		_task("encode", "city", cities[0], fold(cities[0])),
		_task("encode", "callsign", cs, fold(cs)),
		_task("decode", "word", words[0], fold(words[0])),
		_task("decode", "city", cities[1], fold(cities[1])),
		_task("decode", "callsign", _fake_callsign(), ""),
	].map(func(t: Dictionary) -> Dictionary:
		if t["answer"] == "":
			t["answer"] = fold(t["shown"])
		return t)


func _task(mode: String, kind: String, shown: String, answer: String) -> Dictionary:
	return {"mode": mode, "kind": kind, "shown": shown, "answer": answer}


func _fake_callsign() -> String:
	var pre := {"de": "DL", "at": "OE", "ch": "HB9", "us": "K", "uk": "G"}.get(Game.country(), "DL") as String
	var s := pre
	if not pre.ends_with("9"):
		s += str(_rng.randi_range(1, 9))
	for k in 3:
		s += char(65 + _rng.randi_range(0, 25))
	return s


## Spoken form of a text: "Hotel Oscar One".
func _spoken(answer: String) -> Array:
	var out: Array = []
	for ch in answer:
		if LETTERS.has(ch):
			out.append(LETTERS[ch])
		else:
			out.append((DIGIT_WORDS[ch] as Array)[0].capitalize())
	return out


## Typed code words -> letters. Unknown words become "?".
func _parse(text: String) -> Array:
	var t := text.to_lower().replace("x-ray", "xray")
	var re := RegEx.new()
	re.compile("[\\s,;.\\-]+")
	var out: Array = []
	for tok in re.sub(t, " ", true).strip_edges().split(" ", false):
		var found := "?"
		for k in LETTERS:
			if str(LETTERS[k]).to_lower().replace("-", "") == tok:
				found = k
		if ALIASES.has(tok):
			found = ALIASES[tok]
		for d in DIGIT_WORDS:
			if tok == d or (DIGIT_WORDS[d] as Array).has(tok):
				found = d
		out.append(found)
	return out


# ---- ask --------------------------------------------------------------------------------

func _build_ask() -> void:
	var t: Dictionary = _tasks[_i]
	add_lbl(I18n.t("spell.word_n", [_i + 1, ROUNDS]), Vector2(556, 142), 400, 15, Palette.AMBER, Style.font_body_bold)
	for k in ROUNDS:
		var d := Panel.new()
		d.position = Vector2(1100 + (k - ROUNDS) * 0 + k * 18 - 40, 146)
		d.size = Vector2(12, 12)
		d.add_theme_stylebox_override("panel", Style.box(Palette.TEAL if k <= _i else Palette.LINE, 6))
		add_child(d)
	if t["mode"] == "encode":
		add_lbl(I18n.t("spell.encode", [I18n.t("spell.kind." + t["kind"])]), Vector2(556, 178), 628, 19, Palette.CREAM)
		add_title(str(t["shown"]), Vector2(556, 214), 56, Palette.AMBER, 628)
	else:
		add_lbl(I18n.t("spell.decode", [I18n.t("spell.kind.d_" + t["kind"])]), Vector2(556, 178), 628, 19, Palette.CREAM)
		if _audio_only():
			add_title("· · ·", Vector2(556, 214), 34, Palette.AMBER, 628)
			add_lbl(I18n.t("spell.audio_hidden"), Vector2(556, 290), 628, 16, Palette.MUTED)
		else:
			add_title(" ".join(_spoken(t["answer"])), Vector2(556, 214), 34, Palette.AMBER, 628)
		if Voice.usable():
			add_btn(I18n.t("spell.listen"), Vector2(556, 322), _listen, "", Vector2(180, 44))
			add_btn(I18n.t("spell.audio_on") if _audio_only() else I18n.t("spell.audio_off"), Vector2(752, 322), func() -> void:
				Game.set_flag("spell.audio_only", not Game.fact_bool("spell.audio_only"))
				_typed = _edit.text if _edit else _typed
				_rebuild(), "", Vector2(250, 44))
	_edit = LineEdit.new()
	_edit.position = Vector2(556, 380)
	_edit.size = Vector2(628, 56)
	_edit.custom_minimum_size = Vector2(628, 56)
	_edit.text = _typed
	_edit.placeholder_text = I18n.t("spell.ph_encode") if t["mode"] == "encode" else I18n.t("spell.ph_decode")
	_edit.text_submitted.connect(func(_s: String) -> void: _check())
	add_child(_edit)
	_edit.grab_focus()
	_hint_lbl = add_lbl("", Vector2(556, 448), 628, 18, Palette.TEAL, Style.font_body_bold)
	if _hint:
		_show_hint()
	add_btn(I18n.t("spell.check"), Vector2(964, 540), _check, "PrimaryButton", Vector2(220, 52))
	if t["mode"] == "encode":
		add_btn(I18n.t("spell.hint"), Vector2(556, 540), func() -> void:
			_hint = true
			_show_hint(), "", Vector2(140, 52))


func _show_hint() -> void:
	var t: Dictionary = _tasks[_i]
	var got := _parse(_edit.text)
	var ans: String = t["answer"]
	var k := 0
	while k < got.size() and k < ans.length() and got[k] == ans[k]:
		k += 1
	k = mini(k, ans.length() - 1)
	var sp: Array = _spoken(ans)
	_hint_lbl.text = "%s: %s" % [I18n.t("spell.hint"), sp[k]]


func _check() -> void:
	var t: Dictionary = _tasks[_i]
	_typed = _edit.text
	if t["mode"] == "encode":
		var got := _parse(_typed)
		_fb_ok = got.size() == (t["answer"] as String).length()
		if _fb_ok:
			for k in got.size():
				if got[k] != (t["answer"] as String)[k]:
					_fb_ok = false
	else:
		_fb_ok = fold(_typed) == t["answer"]
	if _fb_ok and not _hint:
		_score += 1
	if _fb_ok:
		Sfx.good()
	else:
		Sfx.bad()
	_state = "feedback"
	_rebuild()


# ---- feedback and result ----------------------------------------------------------------

func _build_feedback() -> void:
	var t: Dictionary = _tasks[_i]
	add_lbl(I18n.t("spell.word_n", [_i + 1, ROUNDS]), Vector2(556, 142), 400, 15, Palette.AMBER, Style.font_body_bold)
	add_title(I18n.t("spell.right") if _fb_ok else I18n.t("spell.wrong"), Vector2(556, 180), 34, Palette.GREEN if _fb_ok else Palette.CORAL, 628)
	var correct: String = " ".join(_spoken(t["answer"])) if t["mode"] == "encode" else str(t["answer"])
	add_lbl(correct, Vector2(556, 240), 628, 26, Palette.CREAM, Style.font_display)
	if t["mode"] == "decode":
		add_lbl(" ".join(_spoken(t["answer"])), Vector2(556, 300), 628, 17, Palette.MUTED)
	if _typed.strip_edges() != "":
		add_lbl("> " + _typed, Vector2(556, 380), 628, 17, Palette.MUTED)
	if _fb_ok and _hint:
		add_lbl(I18n.t("spell.hint_used"), Vector2(556, 420), 400, 15, Palette.AMBER)
	if Voice.usable():
		add_btn(I18n.t("spell.listen"), Vector2(556, 470), _listen, "", Vector2(180, 44))
	var last := _i == ROUNDS - 1
	add_btn(I18n.t("spell.finish") if last else I18n.t("spell.next"), Vector2(964, 540), func() -> void:
		if last:
			_finish()
		else:
			_i += 1
			_begin_task(), "PrimaryButton", Vector2(220, 52))


func _finish() -> void:
	Game.stat_add("spell")
	Game.set_flag("spell.best", maxi(Game.fact_int("spell.best", 0), _score))
	if _score >= PASS:
		Game.set_flag("spell.passed", true)
		Sfx.reward()
	_state = "result"
	_rebuild()


func _build_result() -> void:
	var ok := _score >= PASS
	add_title(I18n.t("spell.result", [_score, ROUNDS]), Vector2(556, 160), 40, Palette.GREEN if ok else Palette.CORAL, 628)
	add_lbl(I18n.t("spell.passed") if ok else I18n.t("spell.failed", [PASS]), Vector2(556, 240), 628, 22, Palette.CREAM, Style.font_body_bold)
	add_btn(I18n.t("common.retry"), Vector2(556, 520), _start, "PrimaryButton", Vector2(220, 52))
	add_btn(I18n.t("build.back"), Vector2(800, 520), func() -> void: SceneManager.go("hub"), "", Vector2(260, 52))
