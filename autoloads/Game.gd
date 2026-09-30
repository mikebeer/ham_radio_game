extends Node
## Player profile, progress helpers and save/load. Progress itself lives in FactDatabase
## (galene) and is evaluated by QuestSystem (galene) using resources/quests_cfg/ham.cfg.

signal part_awarded(part_id: String)
signal goal_completed(quest_id: String)

const SAVE_PATH := "user://cq_quest_save.json"
const PART_IDS: Array = ["psu", "antenna", "transceiver", "mic", "speaker", "swr", "key", "logbook"]
const QUEST_IDS: Array = ["rules", "shack", "qso", "morse"]
const MORSE_LEVELS := 10
const AVATAR_COUNT := 6
const QSO_STEPS := 5

var profile: Dictionary = {"name": "", "avatar": 1, "country": "de", "locale": "", "started": false}


func _ready() -> void:
	QuestSystem.quest_completed.connect(func(id: String) -> void: goal_completed.emit(id))
	load_game()


# ---- lifecycle --------------------------------------------------------------------------

func begin_new_game(name: String, avatar: int, country: String) -> void:
	FactDatabase.clear_all()
	Global.reset()
	for q in QUEST_IDS:
		QuestSystem.reset_quest(q)
	profile = {"name": name.strip_edges(), "avatar": avatar, "country": country, "locale": I18n.locale, "started": true}
	FactDatabase.set_fact("rules.country", country)
	_start_quests()
	save_game()


func reset_all() -> void:
	FactDatabase.clear_all()
	Global.reset()
	for q in QUEST_IDS:
		QuestSystem.reset_quest(q)
	profile = {"name": "", "avatar": 1, "country": "de", "locale": "", "started": false}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _start_quests() -> void:
	for q in QUEST_IDS:
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


func callsign() -> String:
	return str(pack().get("callsign", "N0CALL"))


func fact_int(key: String, default: int = 0) -> int:
	return int(FactDatabase.get_fact(key, default))


func owns(part_id: String) -> bool:
	return bool(FactDatabase.get_fact("shack." + part_id, false))


func award(part_id: String) -> void:
	FactDatabase.set_fact("shack." + part_id, true)
	part_awarded.emit(part_id)
	save_game()


func parts_owned() -> int:
	var n := 0
	for p in PART_IDS:
		if owns(p):
			n += 1
	return n


func rules_done() -> bool:
	return bool(FactDatabase.get_fact("goal.rules", false))


func qso_ready() -> bool:
	return rules_done() and owns("transceiver") and owns("antenna") and owns("mic") and owns("psu")


func qso_steps_done() -> int:
	var n := 0
	for k in ["qso.tuned", "qso.answered", "qso.exchanged", "qso.spelled", "qso.done"]:
		if bool(FactDatabase.get_fact(k, false)):
			n += 1
	return n


func morse_passed() -> int:
	return fact_int("morse.passed", 0)


func set_flag(key: String, value = true) -> void:
	FactDatabase.set_fact(key, value)
	save_game()
