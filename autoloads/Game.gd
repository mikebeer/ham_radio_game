extends Node
## Player profile, progress helpers and save/load. Progress itself lives in FactDatabase
## (galene) and is evaluated by QuestSystem (galene) using resources/quests_cfg/ham.cfg.

signal part_awarded(part_id: String)
signal goal_completed(quest_id: String)

const SAVE_PATH := "user://cq_quest_save.json"
const PART_IDS: Array = ["psu", "antenna", "transceiver", "mic", "speaker", "swr", "key", "logbook"]
const QUEST_IDS: Array = ["rules", "shack", "qso", "morse"]
const MAX_LEVELS := 3
const MORSE_LEVELS := 10
const MORSE_CAP := [3, 6, 10]
const AVATAR_COUNT := 6
const QSO_STEPS := 5

var profile: Dictionary = {"name": "", "avatar": 1, "country": "de", "locale": "", "started": false, "level": 1}


func _ready() -> void:
	QuestSystem.quest_completed.connect(func(id: String) -> void: goal_completed.emit(id))
	load_game()


# ---- lifecycle --------------------------------------------------------------------------

func begin_new_game(name: String, avatar: int, country: String) -> void:
	FactDatabase.clear_all()
	Global.reset()
	for q in all_quest_ids():
		QuestSystem.reset_quest(q)
	profile = {"name": name.strip_edges(), "avatar": avatar, "country": country, "locale": I18n.locale, "started": true, "level": 1}
	FactDatabase.set_fact("rules.country", country)
	_start_quests()
	save_game()


func reset_all() -> void:
	FactDatabase.clear_all()
	Global.reset()
	for q in all_quest_ids():
		QuestSystem.reset_quest(q)
	profile = {"name": "", "avatar": 1, "country": "de", "locale": "", "started": false, "level": 1}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _start_quests() -> void:
	for lv in range(1, levels_unlocked() + 1):
		for b in QUEST_IDS:
			var q := quest_id(b, lv)
			if QuestSystem.get_quest_state(q) == QuestSystem.ItemState.INACTIVE:
				QuestSystem.start_quest(q)
	pump()


## QuestSystem re-evaluates on every fact change; a few bumps let auto-started tasks
## settle after loading a save.
func pump() -> void:
	for i in 3:
		FactDatabase.increment_fact("game.tick")


func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"profile": profile, "facts": FactDatabase.snapshot()}))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data = JSON.parse_string(f.get_as_text())
	if not (data is Dictionary):
		return
	var prof = data.get("profile", {})
	if prof is Dictionary and prof.get("started", false):
		profile = prof
		var loc: String = str(prof.get("locale", ""))
		if loc != "":
			I18n.set_locale(loc)
		FactDatabase.restore(data.get("facts", {}))
		_start_quests()


# ---- progress helpers -------------------------------------------------------------------

func has_save() -> bool:
	return bool(profile.get("started", false))


func country() -> String:
	return str(profile.get("country", "de"))


func pack() -> Dictionary:
	return Content.legal_pack(country())


## The callsign the player picked in the directory, or the country's practice callsign.
func callsign() -> String:
	var own := str(profile.get("callsign", ""))
	return own if own != "" else str(pack().get("callsign", "N0CALL"))


func has_callsign() -> bool:
	return str(profile.get("callsign", "")) != ""


func set_callsign(cs: String) -> void:
	profile["callsign"] = cs
	FactDatabase.set_fact("rules.callsign", cs != "")
	save_game()


func set_profile(name: String, avatar: int) -> void:
	profile["name"] = name.strip_edges()
	profile["avatar"] = avatar
	save_game()


## Changing the country restarts the rules goals (different rules) and gives the callsign back.
func change_country(c: String) -> void:
	if c == country():
		return
	profile["country"] = c
	profile["callsign"] = ""
	for lv in range(1, MAX_LEVELS + 1):
		QuestSystem.reset_quest(quest_id("rules", lv))
		for key in ["rules.lessons_done", "rules.lessons_all", "rules.quiz_passed", "goal.rules"]:
			FactDatabase.set_fact(k(key, lv), 0 if key == "rules.lessons_done" else false)
		FactDatabase.set_fact("level.unlocked", 1)
	FactDatabase.set_fact("rules.callsign", false)
	FactDatabase.set_fact("rules.country", c)
	profile["level"] = 1
	_start_quests()
	save_game()


func fact_int(key: String, default: int = 0) -> int:
	return int(FactDatabase.get_fact(key, default))


# ---- levels -----------------------------------------------------------------------------
# Level 1 = entry class (plain fact names), level 2/3 = higher classes (facts prefixed "l2.").

func all_quest_ids() -> Array:
	var out: Array = []
	for lv in range(1, MAX_LEVELS + 1):
		for b in QUEST_IDS:
			out.append(quest_id(b, lv))
	return out


func quest_id(base: String, level: int = 0) -> String:
	var l := level if level > 0 else cur_level()
	return base if l == 1 else "%s%d" % [base, l]


## Fact key for the given level (0 = current level).
func k(key: String, level: int = 0) -> String:
	var l := level if level > 0 else cur_level()
	return key if l == 1 else "l%d.%s" % [l, key]


func cur_level() -> int:
	return clampi(int(profile.get("level", 1)), 1, maxi(1, level_count()))


func set_level(n: int) -> void:
	profile["level"] = clampi(n, 1, levels_unlocked())
	save_game()


func level_count() -> int:
	return mini(MAX_LEVELS, (pack().get("levels", []) as Array).size())


func level_data(level: int = 0) -> Dictionary:
	var l := level if level > 0 else cur_level()
	var lvls: Array = pack().get("levels", [])
	return lvls[clampi(l, 1, lvls.size()) - 1] if lvls.size() > 0 else {}


func levels_unlocked() -> int:
	return clampi(fact_int("level.unlocked", 1), 1, maxi(1, level_count()))


func goal_done(base: String, level: int = 0) -> bool:
	return bool(FactDatabase.get_fact(k("goal." + base, level), false))


func level_done(level: int = 0) -> bool:
	for b in QUEST_IDS:
		if not goal_done(b, level):
			return false
	return true


## Unlocks the next level when the highest unlocked one is complete. Returns the new level or 0.
func check_level_up() -> int:
	var u := levels_unlocked()
	if u < level_count() and level_done(u):
		FactDatabase.set_fact("level.unlocked", u + 1)
		_start_quests()
		profile["level"] = u + 1
		save_game()
		return u + 1
	return 0


# ---- progress helpers (all default to the current level) --------------------------------

func owns(part_id: String, level: int = 0) -> bool:
	return bool(FactDatabase.get_fact(k("shack." + part_id, level), false))


## Highest level at which the part was earned (0 = not owned yet).
func tier(part_id: String) -> int:
	var t := 0
	for l in range(1, MAX_LEVELS + 1):
		if owns(part_id, l):
			t = l
	return t


func award(part_id: String) -> void:
	FactDatabase.set_fact(k("shack." + part_id), true)
	part_awarded.emit(part_id)
	save_game()


func parts_owned(level: int = 0) -> int:
	var n := 0
	for p in PART_IDS:
		if owns(p, level):
			n += 1
	return n


func rules_done(level: int = 0) -> bool:
	return bool(FactDatabase.get_fact(k("goal.rules", level), false))


func qso_ready() -> bool:
	return rules_done() and owns("transceiver") and owns("antenna") and owns("mic") and owns("psu")


func qso_steps_done(level: int = 0) -> int:
	var n := 0
	for key in ["qso.tuned", "qso.answered", "qso.exchanged", "qso.spelled", "qso.done"]:
		if bool(FactDatabase.get_fact(k(key, level), false)):
			n += 1
	return n


func morse_passed() -> int:
	return fact_int("morse.passed", 0)


func morse_cap(level: int = 0) -> int:
	return int(MORSE_CAP[(level if level > 0 else cur_level()) - 1])


func set_flag(key: String, value = true) -> void:
	FactDatabase.set_fact(key, value)
	save_game()
