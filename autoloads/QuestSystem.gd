# Copied unchanged from mikebeer/galene (mvp/0.5/autoloads).
# =============================================================================
# QuestSystem.gd  —  Autoload singleton — Godot 4.6
#
# Hierarchy:  Chapter  >  Quest  >  Task
#
# TRACKING RULES:
#   - Only ONE quest can be tracked at a time.
#   - Clicking "Track" on a quest un-tracks all others first.
#   - When a tracked main quest completes and has a next_quest, that next
#     quest is automatically tracked (main quests only, not side quests).
#   - Tracking is cleared when a quest fails or is reset.
#
# ENTITY MARKERS:
#   - Tasks carry an "entities" field: JSON array of entity descriptors.
#   - Each entity: {"id":"npc_mayor","label":"Mayor","x":220,"y":390}
#   - The TaskMarkerLayer autoload reads get_active_task_entities() and
#     draws markers on screen over every entity of the currently tracked
#     quest's active tasks.
#
# CFG file format  (resources/quests_cfg/*.cfg):
#
#   [chapter.ID]
#   display_name = "..."
#   description  = "..."
#
#   [quest.ID]
#   chapter          = "chapter_id"
#   type             = "main"           ; "main" or "side"
#   display_name     = "..."
#   description      = "..."
#   start_conditions = "[...]"          ; JSON — all must pass before user can start
#   fail_conditions  = "[...]"          ; JSON — any one passes → FAILED
#   on_start_facts   = "{...}"          ; JSON — facts written on ACTIVE
#   on_complete_facts= "{...}"          ; JSON — facts written on COMPLETED
#   on_fail_facts    = "{...}"          ; JSON — facts written on FAILED
#   reward_items     = "gold_50,..."    ; informational string
#   add_todo         = "..."            ; creates ToDoManager item(s) on COMPLETED — see below
#   next_quest       = "quest_id"       ; auto-started (and auto-tracked if main) on completion
#
#   [task.QUEST_ID.TASK_ID]
#   display_name     = "..."
#   description      = "..."
#   auto_start       = true             ; start immediately when parent quest activates
#   start_conditions = "[...]"          ; OR start when these pass (parent must be ACTIVE)
#   fail_conditions  = "[...]"
#   goal_conditions  = "[...]"          ; ALL must pass → COMPLETED
#   on_start_facts   = "{...}"
#   on_complete_facts= "{...}"
#   on_fail_facts    = "{...}"
#   reward_items     = "gold_50,..."
#   add_todo         = "..."            ; creates ToDoManager item(s) on COMPLETED — see below
#   optional         = false            ; if true, task failure does not fail quest
#   entities         = "[...]"          ; JSON array of involved NPCs/objects:
#                                       ;   [{"id":"npc_mayor","label":"Mayor","x":220,"y":390},
#                                       ;    {"id":"village_chest","label":"Chest","x":560,"y":430}]
#
# add_todo syntax (quest AND task level - fires when that quest/task
# reaches COMPLETED, alongside reward_items). Two formats, distinguished
# by whether the value contains a "{" anywhere:
#
#   SIMPLE (no "{"): the entire string is the activity text, verbatim.
#   Every parameter (repeat, category, reward, due_in_days) is left at
#   its default. No escaping, no syntax - just the activity:
#
#     add_todo = "Trink heute 2 Liter Wasser"
#
#   JSON (contains "{"): a single object, or an array of objects for
#   multiple to-do items from one quest/task. Recognized keys: "activity"
#   (required), "repeat" ("daily"/"weekly"/"monthly"), "category"
#   ("story"/"intervention"/"real_world", default "story"), "reward"
#   (same "name_amount" token as reward_items, e.g. "coins_5"),
#   "due_in_days" (integer; due date = completion time + N days).
#
#     add_todo = "{\"activity\":\"Trink heute 2 Liter Wasser\",\"repeat\":\"daily\",\"category\":\"health\"}"
#
#     add_todo = "[{\"activity\":\"Trink heute 2 Liter Wasser\",\"repeat\":\"daily\"},
#                  {\"activity\":\"Geh 10 Minuten spazieren\",\"reward\":\"coins_2\"}]"
#
#   A plain activity description essentially never contains a literal
#   "{", which is what makes this a safe, unambiguous discriminator - no
#   separate flag or key is needed to say which format is being used.
#
#   Items are created via ToDoManager.add_item(..., source=SOURCE_API) -
#   they show up exactly like any other to-do, but are attributed to the
#   quest system rather than the player, and are silently skipped (with a
#   warning) if the ToDoManager autoload isn't present in this project.
#   add_todo itself is entirely optional - a quest/task that never
#   mentions it behaves exactly as it did before this feature existed.
# =============================================================================
extends Node

# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------
enum ItemState { INACTIVE, ACTIVE, COMPLETED, FAILED }
enum QuestType  { MAIN, SIDE }

# ---------------------------------------------------------------------------
# Inner classes
# ---------------------------------------------------------------------------

class TaskRecord:
	var id           : String   # "quest_id.task_id"
	var quest_id     : String
	var task_id      : String
	var state        : int = 0  # ItemState int
	var definition   : Dictionary = {}
	var started_at   : int = 0
	var completed_at : int = 0
	func _init(full: String, qid: String, tid: String, def: Dictionary) -> void:
		id = full; quest_id = qid; task_id = tid; definition = def


class QuestRecord:
	var id           : String
	var chapter_id   : String
	var quest_type   : int = 0  # QuestType int
	var state        : int = 0  # ItemState int
	var definition   : Dictionary = {}
	var task_ids     : Array = []
	var tracked      : bool = false
	var started_at   : int = 0
	var completed_at : int = 0
	func _init(p_id: String, def: Dictionary) -> void:
		id         = p_id
		definition = def
		chapter_id = def.get("chapter", "")
		quest_type = QuestSystem.QuestType.MAIN if def.get("type","main") == "main" \
					 else QuestSystem.QuestType.SIDE


class ChapterRecord:
	var id         : String
	var state      : int = 0
	var definition : Dictionary = {}
	var quest_ids  : Array = []
	func _init(p_id: String, def: Dictionary) -> void:
		id = p_id; definition = def

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------
signal chapter_completed(chapter_id: String)
signal quest_registered(quest_id: String)
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal quest_state_changed(quest_id: String, old_state: int, new_state: int)
## Emitted when the single tracked quest changes.
## new_quest_id is "" when tracking is cleared.
signal tracking_changed(new_quest_id: String)
signal task_started(task_id: String)
signal task_completed(task_id: String)
signal task_failed(task_id: String)
signal reward_granted(type: String, amount: int)
signal reward_item_granted(item_id: String)
signal spend_applied(type: String, amount: int)
signal spend_item_required(item_id: String)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
const QUEST_CFG_DIR := "res://resources/quests_cfg/"

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var _chapters       : Dictionary = {}
var _quests         : Dictionary = {}
var _tasks          : Dictionary = {}
var _tracked_quest  : String     = ""   # at most one quest is tracked at a time

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_load_all_quest_configs()
	FactDatabase.fact_changed.connect(_on_fact_changed)
	FactDatabase.fact_removed.connect(_on_fact_changed.bind("", null))

func _on_fact_changed(_k = "", _o = null, _n = null) -> void:
	_tick()

## Returns the raw TaskRecord for a task id. Returns null if unknown.
func get_task_record(full_task_id: String):
	return _tasks.get(full_task_id, null)
	
# ---------------------------------------------------------------------------
# Public API — starting (user API)
# ---------------------------------------------------------------------------

## Start a quest. Only quests can be started by user code; tasks start
## automatically once their parent quest is active.
## Returns false if the quest is unknown, not INACTIVE, or not available on
## the current island (see is_quest_island_ok()).
func start_quest(quest_id: String) -> bool:
	if not _quests.has(quest_id):
		push_error("QuestSystem: Unknown quest '%s'" % quest_id)
		return false
	var rec = _quests[quest_id]
	if rec.state != ItemState.INACTIVE:
		push_warning("QuestSystem: quest '%s' already %s" % [quest_id, state_name(rec.state)])
		return false
	if not is_quest_island_ok(quest_id):
		push_warning("QuestSystem: quest '%s' not available on the current island" % quest_id)
		return false
	_quest_transition(rec, ItemState.ACTIVE)
	return true


## Force a quest to COMPLETED regardless of task state. Dev/debug tool.
func complete_quest(quest_id: String) -> bool:
	if not _quests.has(quest_id): return false
	_quest_transition(_quests[quest_id], ItemState.COMPLETED)
	return true


## Force a quest to FAILED.
func fail_quest(quest_id: String) -> bool:
	if not _quests.has(quest_id): return false
	_quest_transition(_quests[quest_id], ItemState.FAILED)
	return true


## Reset a quest and all its tasks to INACTIVE.
func reset_quest(quest_id: String) -> bool:
	if not _quests.has(quest_id): return false
	var rec = _quests[quest_id]
	for tid in rec.task_ids:
		if _tasks.has(tid): _tasks[tid].state = ItemState.INACTIVE
	if _tracked_quest == quest_id:
		_set_tracking("")
	_quest_transition(rec, ItemState.INACTIVE)
	return true


## Start a task manually, bypassing start_conditions.
## The parent quest must already be ACTIVE.
func start_task(full_task_id: String) -> bool:
	if not _tasks.has(full_task_id):
		push_error("QuestSystem: Unknown task '%s'" % full_task_id)
		return false
	var rec = _tasks[full_task_id]
	if rec.state != ItemState.INACTIVE: return false
	_task_transition(rec, ItemState.ACTIVE)
	return true


## Force a task to COMPLETED.
func complete_task(full_task_id: String) -> bool:
	if not _tasks.has(full_task_id): return false
	_task_transition(_tasks[full_task_id], ItemState.COMPLETED)
	return true

# ---------------------------------------------------------------------------
# Public API — single-slot tracking
# ---------------------------------------------------------------------------

## Track a quest. Un-tracks any previously tracked quest first (single slot).
## Pass "" to clear tracking entirely.
func track_quest(quest_id: String) -> void:
	if quest_id != "" and not _quests.has(quest_id):
		push_warning("QuestSystem: track_quest — unknown quest '%s'" % quest_id)
		return
	_set_tracking(quest_id)


## Returns the id of the currently tracked quest, or "" if none.
func get_tracked_quest() -> String:
	return _tracked_quest


## Returns true if the given quest is currently tracked.
func is_quest_tracked(quest_id: String) -> bool:
	return _tracked_quest == quest_id


## Returns all active tasks belonging to the tracked quest, as an Array of
## task summary dicts.  Used by TaskMarkerLayer to draw entity markers.
func get_tracked_active_tasks() -> Array:
	if _tracked_quest == "":
		return []
	var result = []
	for tid in get_tasks_for_quest(_tracked_quest):
		var trec = _tasks.get(tid, null)
		if trec != null and trec.state == ItemState.ACTIVE:
			result.append(get_task_summary(tid))
	return result


## Returns all entity descriptors for the tracked quest's active tasks.
## Each entry: {"id": String, "label": String, "x": float, "y": float}
func get_active_task_entities() -> Array:
	var result = []
	for task_summary in get_tracked_active_tasks():
		for entity in task_summary.get("entities", []):
			result.append(entity)
	return result

# ---------------------------------------------------------------------------
# Public API — queries
# ---------------------------------------------------------------------------

## State enum int for a quest. Returns INACTIVE if unknown.
func get_quest_state(quest_id: String) -> int:
	return _quests[quest_id].state if _quests.has(quest_id) else ItemState.INACTIVE

## State enum int for a task.
func get_task_state(full_task_id: String) -> int:
	return _tasks[full_task_id].state if _tasks.has(full_task_id) else ItemState.INACTIVE

func is_quest_active(quest_id: String) -> bool:
	return get_quest_state(quest_id) == ItemState.ACTIVE

func is_quest_completed(quest_id: String) -> bool:
	return get_quest_state(quest_id) == ItemState.COMPLETED

func is_task_completed(full_task_id: String) -> bool:
	return get_task_state(full_task_id) == ItemState.COMPLETED

## True if the given chapter's "valid_for" restriction (a comma-separated
## list of island names in its cfg, e.g. valid_for = "Gra,Upu-Upu") allows
## the current island, per Global.current_island(). Chapters with no
## valid_for (or an empty one) are "generic" and always allowed, on any
## island, including before an island has been set at all. Comparison is
## case-insensitive (both sides lowercased). If the current island is
## unset/empty, a chapter WITH a valid_for restriction is NOT allowed
## (fail-closed) - only generic chapters pass in that state.
func is_chapter_island_ok(chapter_id: String) -> bool:
	var crec = _chapters.get(chapter_id, null)
	if crec == null:
		return true  # unknown chapter - nothing to restrict against
	var valid_for: String = String(crec.definition.get("valid_for", "")).strip_edges()
	if valid_for == "":
		return true  # generic chapter - always allowed
	if typeof(Global) == TYPE_NIL or not Global.has_method("current_island"):
		return false  # can't determine current island - fail closed
	var current: String = String(Global.current_island()).strip_edges().to_lower()
	if current == "":
		return false  # no island set yet - fail closed for restricted chapters
	for island in valid_for.split(","):
		var island_norm: String = island.strip_edges().to_lower()
		# Story chapters use "<island>_story" in valid_for (e.g. "gra_story")
		# to distinguish them from the evidence-based "<island>" chapters
		# already tagged with the plain island name - strip that suffix
		# before comparing, so island matching itself is unaffected by
		# which type of chapter this is. See is_chapter_story() for the
		# type check itself.
		if island_norm.ends_with("_story"):
			island_norm = island_norm.substr(0, island_norm.length() - len("_story"))
		if island_norm == current:
			return true
	return false

## True if ANY of the chapter's valid_for entries end in "_story" - i.e.
## this is a narrative/story chapter, as opposed to an evidence-based
## intervention chapter tagged with a plain island name. Generic chapters
## (no valid_for, e.g. wellbeing) are never considered story chapters.
## Used by qm.gd's Global.get_common("qm_type") filter ("all"/""/"story"/
## "intervention"/"iv").
func is_chapter_story(chapter_id: String) -> bool:
	var crec = _chapters.get(chapter_id, null)
	if crec == null:
		return false
	var valid_for: String = String(crec.definition.get("valid_for", "")).strip_edges()
	if valid_for == "":
		return false
	for island in valid_for.split(","):
		if island.strip_edges().to_lower().ends_with("_story"):
			return true
	return false

## True if the given quest's chapter allows the current island. See
## is_chapter_island_ok(). Unknown quests return false (nothing to allow).
func is_quest_island_ok(quest_id: String) -> bool:
	if not _quests.has(quest_id):
		return false
	return is_chapter_island_ok(_quests[quest_id].chapter_id)

## All chapter ids allowed on the current island (includes generic ones).
## Convenience for UI code (e.g. qm.gd's island-filter toggle) that wants to
## filter a chapter list in one call rather than checking each id itself.
func get_chapters_for_current_island() -> Array:
	var r = []
	for cid in _chapters:
		if is_chapter_island_ok(cid):
			r.append(cid)
	return r

## All quest ids in a given ItemState.
func get_quests_by_state(s: int) -> Array:
	var r = []
	for id in _quests:
		if _quests[id].state == s: r.append(id)
	return r

## All chapter ids in registration order.
func get_all_chapters() -> Array:
	return _chapters.keys()

## Quest ids belonging to a chapter, in registration order.
func get_quests_for_chapter(chapter_id: String) -> Array:
	if not _chapters.has(chapter_id): return []
	return _chapters[chapter_id].quest_ids.duplicate()

## Task full-ids belonging to a quest, in registration order.
func get_tasks_for_quest(quest_id: String) -> Array:
	if not _quests.has(quest_id): return []
	return _quests[quest_id].task_ids.duplicate()

## Full summary Dictionary for a quest.
## Keys: id, chapter_id, type ("main"/"side"), display_name, description,
##       state (String), state_enum (int), tracked (bool),
##       reward_items (String), task_ids (Array[String])
func get_quest_summary(quest_id: String) -> Dictionary:
	var rec = _quests.get(quest_id, null)
	if rec == null: return {}
	var def = rec.definition
	return {
		"id":            quest_id,
		"chapter_id":    rec.chapter_id,
		"type":          "main" if rec.quest_type == QuestType.MAIN else "side",
		"display_name":  def.get("display_name", quest_id),
		"description":   def.get("description", ""),
		"state":         state_name(rec.state),
		"state_enum":    rec.state,
		"tracked":       rec.tracked,
		"reward_items":  def.get("reward_items", ""),
		"task_ids":      rec.task_ids.duplicate(),
	}

## Full summary Dictionary for a task.
## Keys: id, quest_id, task_id, display_name, description,
##       state (String), state_enum (int), optional (bool),
##       entities (Array[Dict]) where each dict has id, label, x, y
func get_task_summary(full_task_id: String) -> Dictionary:
	var rec = _tasks.get(full_task_id, null)
	if rec == null: return {}
	var def = rec.definition
	return {
		"id":           full_task_id,
		"quest_id":     rec.quest_id,
		"task_id":      rec.task_id,
		"display_name": def.get("display_name", full_task_id),
		"description":  def.get("description", ""),
		"state":        state_name(rec.state),
		"state_enum":   rec.state,
		"optional":     def.get("optional", false),
		"entities":     def.get("entities", []),
	}

## Summary Dictionary for a chapter.
## Keys: id, display_name, description, state (String), state_enum (int), quest_ids
func get_chapter_summary(chapter_id: String) -> Dictionary:
	var rec = _chapters.get(chapter_id, null)
	if rec == null: return {}
	return {
		"id":           chapter_id,
		"display_name": rec.definition.get("display_name", chapter_id),
		"description":  rec.definition.get("description", ""),
		"state":        state_name(rec.state),
		"state_enum":   rec.state,
		"quest_ids":    rec.quest_ids.duplicate(),
	}

## Human-readable state string. Public for use by HUD and other systems.
func state_name(s: int) -> String:
	match s:
		ItemState.INACTIVE:   return "INACTIVE"
		ItemState.ACTIVE:     return "ACTIVE"
		ItemState.COMPLETED:  return "COMPLETED"
		ItemState.FAILED:     return "FAILED"
	return "UNKNOWN"

## Returns the raw QuestRecord for a quest id. Used by SaveLoad.
## Returns null if unknown.
func get_quest_record(quest_id: String):
	return _quests.get(quest_id, null)

## Hot-reload all cfg files while preserving current runtime states.
func reload_quest_configs() -> void:
	var oq = {}; for id in _quests: oq[id] = _quests[id].state
	var ot = {}; for id in _tasks:  ot[id] = _tasks[id].state
	var tracked = _tracked_quest
	_chapters.clear(); _quests.clear(); _tasks.clear()
	_load_all_quest_configs()
	for id in oq:
		if _quests.has(id): _quests[id].state = oq[id]
	for id in ot:
		if _tasks.has(id):  _tasks[id].state  = ot[id]
	if tracked != "" and _quests.has(tracked):
		_quests[tracked].tracked = true
		_tracked_quest = tracked

# ---------------------------------------------------------------------------
# Private — config loading
# ---------------------------------------------------------------------------

func _load_all_quest_configs() -> void:
	var dir = DirAccess.open(QUEST_CFG_DIR)
	if dir == null:
		push_warning("QuestSystem: cfg dir not found: %s" % QUEST_CFG_DIR)
		return
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.ends_with(".cfg"):
			_load_quest_config(QUEST_CFG_DIR + fname)
		fname = dir.get_next()
	dir.list_dir_end()
	print("QuestSystem: %d chapters, %d quests, %d tasks." \
		% [_chapters.size(), _quests.size(), _tasks.size()])


func _load_quest_config(path: String) -> void:
	var cfg = ConfigFile.new()
	if cfg.load(path) != OK:
		push_error("QuestSystem: cannot load '%s'" % path)
		return
	for section in cfg.get_sections():
		var parts = section.split(".", false)
		match parts[0]:
			"chapter":
				if parts.size() < 2: continue
				var rec = ChapterRecord.new(parts[1], _read_section(cfg, section))
				_chapters[parts[1]] = rec

			"quest":
				if parts.size() < 2: continue
				var qid = parts[1]
				var def = _read_section(cfg, section)
				var rec = QuestRecord.new(qid, def)
				_quests[qid] = rec
				var cid = def.get("chapter", "")
				if cid != "" and _chapters.has(cid):
					if not _chapters[cid].quest_ids.has(qid):
						_chapters[cid].quest_ids.append(qid)
				emit_signal("quest_registered", qid)

			"task":
				if parts.size() < 3: continue
				var qid     = parts[1]
				var tid     = parts[2]
				var full_id = qid + "." + tid
				var def     = _read_section(cfg, section)
				var rec     = TaskRecord.new(full_id, qid, tid, def)
				_tasks[full_id] = rec
				if _quests.has(qid) and not _quests[qid].task_ids.has(full_id):
					_quests[qid].task_ids.append(full_id)


func _read_section(cfg: ConfigFile, section: String) -> Dictionary:
	var def = {}
	for key in cfg.get_section_keys(section):
		def[key] = cfg.get_value(section, key)
	for jk in ["start_conditions","fail_conditions","goal_conditions"]:
		if def.has(jk): def[jk] = _parse_json_array(def[jk])
	for jk in ["on_start_facts","on_complete_facts","on_fail_facts"]:
		if def.has(jk): def[jk] = _parse_json_dict(def[jk])
	if def.has("entities"):
		def["entities"] = _parse_json_array(def["entities"])
	return def

# ---------------------------------------------------------------------------
# Private — tick (called on every fact change)
# ---------------------------------------------------------------------------

func _tick() -> void:
	# Tasks
	for tid in _tasks:
		var trec = _tasks[tid]
		if trec.state == ItemState.COMPLETED or trec.state == ItemState.FAILED:
			continue
		var qrec = _quests.get(trec.quest_id, null)
		if qrec == null or qrec.state != ItemState.ACTIVE:
			continue
		if trec.state == ItemState.INACTIVE:
			var auto = trec.definition.get("auto_start", false)
			var conds = trec.definition.get("start_conditions", [])
			if auto or (not conds.is_empty() and FactDatabase.eval_conditions(conds)):
				_task_transition(trec, ItemState.ACTIVE)
			continue
		if trec.state == ItemState.ACTIVE:
			var fc = trec.definition.get("fail_conditions", [])
			if not fc.is_empty() and FactDatabase.eval_conditions_or(fc):
				_task_transition(trec, ItemState.FAILED); continue
			var gc = trec.definition.get("goal_conditions", [])
			if not gc.is_empty() and FactDatabase.eval_conditions(gc):
				_task_transition(trec, ItemState.COMPLETED)

	# Quests
	for qid in _quests:
		var qrec = _quests[qid]
		if qrec.state != ItemState.ACTIVE: continue
		var fc = qrec.definition.get("fail_conditions", [])
		if not fc.is_empty() and FactDatabase.eval_conditions_or(fc):
			_quest_transition(qrec, ItemState.FAILED); continue
		_check_quest_completion(qrec)

	# Chapters
	for cid in _chapters:
		var crec = _chapters[cid]
		if crec.state == ItemState.COMPLETED: continue
		if crec.quest_ids.is_empty(): continue
		var done = true
		for qid in crec.quest_ids:
			if not _quests.has(qid) or _quests[qid].state != ItemState.COMPLETED:
				done = false; break
		if done:
			crec.state = ItemState.COMPLETED
			emit_signal("chapter_completed", cid)
			print("QuestSystem: Chapter DONE '%s'" % cid)


func _check_quest_completion(qrec: QuestRecord) -> void:
	if qrec.task_ids.is_empty(): return
	for tid in qrec.task_ids:
		var trec = _tasks.get(tid, null)
		if trec == null: continue
		if trec.definition.get("optional", false): continue
		if trec.state != ItemState.COMPLETED: return
	_quest_transition(qrec, ItemState.COMPLETED)

# ---------------------------------------------------------------------------
# Private — transitions
# ---------------------------------------------------------------------------

func _quest_transition(rec: QuestRecord, new_state: int) -> void:
	var old = rec.state
	rec.state = new_state
	match new_state:
		ItemState.ACTIVE:
			rec.started_at = Time.get_ticks_msec()
			_apply_facts(rec.definition.get("on_start_facts", {}))
			_spend_on_entry(rec.definition.get("spend_on_entry", ""))
			emit_signal("quest_started", rec.id)
			print("QuestSystem: STARTED quest '%s'" % rec.id)
			_tick()

		ItemState.COMPLETED:
			rec.completed_at = Time.get_ticks_msec()
			_apply_facts(rec.definition.get("on_complete_facts", {}))
			_grant_rewards(rec.definition.get("reward_items", ""))
			_apply_add_todo(rec.definition.get("add_todo", ""))
			# Auto-track next main quest
			if rec.tracked:
				_set_tracking("")
				var next = rec.definition.get("next_quest", "")
				if next != "" and _quests.has(next) \
						and _quests[next].quest_type == QuestType.MAIN:
					_set_tracking(next)
			emit_signal("quest_completed", rec.id)
			print("QuestSystem: COMPLETED quest '%s'" % rec.id)
			var next = rec.definition.get("next_quest", "")
			if next != "" and _quests.has(next):
				start_quest(next)

		ItemState.FAILED:
			if rec.tracked: _set_tracking("")
			_apply_facts(rec.definition.get("on_fail_facts", {}))
			emit_signal("quest_failed", rec.id)
			print("QuestSystem: FAILED quest '%s'" % rec.id)

		ItemState.INACTIVE:
			pass

	emit_signal("quest_state_changed", rec.id, old, new_state)


func _task_transition(rec: TaskRecord, new_state: int) -> void:
	rec.state = new_state
	match new_state:
		ItemState.ACTIVE:
			rec.started_at = Time.get_ticks_msec()
			_apply_facts(rec.definition.get("on_start_facts", {}))
			_spend_on_entry(rec.definition.get("spend_on_entry", ""))
			emit_signal("task_started", rec.id)
			print("QuestSystem: STARTED task '%s'" % rec.id)

		ItemState.COMPLETED:
			rec.completed_at = Time.get_ticks_msec()
			_apply_facts(rec.definition.get("on_complete_facts", {}))
			_grant_rewards(rec.definition.get("reward_items", ""))
			_apply_add_todo(rec.definition.get("add_todo", ""))
			emit_signal("task_completed", rec.id)
			print("QuestSystem: COMPLETED task '%s'" % rec.id)

		ItemState.FAILED:
			_apply_facts(rec.definition.get("on_fail_facts", {}))
			emit_signal("task_failed", rec.id)
			print("QuestSystem: FAILED task '%s'" % rec.id)

# ---------------------------------------------------------------------------
# Private — tracking
# ---------------------------------------------------------------------------

func _set_tracking(quest_id: String) -> void:
	# Un-track previous
	if _tracked_quest != "" and _quests.has(_tracked_quest):
		_quests[_tracked_quest].tracked = false
	_tracked_quest = quest_id
	# Track new
	if quest_id != "" and _quests.has(quest_id):
		_quests[quest_id].tracked = true
	emit_signal("tracking_changed", quest_id)

# ---------------------------------------------------------------------------
# Private — helpers
# ---------------------------------------------------------------------------

func _apply_facts(d: Dictionary) -> void:
	for k in d: FactDatabase.set_fact(k, d[k])


## Shared parser for reward_items / spend_on_entry - both use the exact
## same comma-separated "name_amount" token format (already established by
## chapter1.cfg/sidequests.cfg's reward_items). sign=+1 grants (rewards),
## sign=-1 spends (entry cost). A token whose text after its LAST
## underscore parses as an integer is a currency token -
## Global.add_points(name, signed_amount). Any other token (no trailing
## integer, e.g. "legendary_shield") is a non-currency item QuestSystem
## has no inventory API for; it only emits a signal so something else can
## react.
func _apply_points_tokens(token_string: String, sign: int) -> void:
	if token_string.strip_edges() == "":
		return
	for raw_token in token_string.split(","):
		var token: String = raw_token.strip_edges()
		if token == "":
			continue
		var sep: int = token.rfind("_")
		var handled = false
		if sep > 0 and sep < token.length() - 1:
			var currency: String = token.substr(0, sep)
			var amount_str: String = token.substr(sep + 1)
			if amount_str.is_valid_int():
				var amount: int = int(amount_str)
				if typeof(Global) != TYPE_NIL and Global.has_method("add_points"):
					Global.add_points(currency, amount * sign)
					if sign > 0:
						emit_signal("reward_granted", currency, amount)
					else:
						emit_signal("spend_applied", currency, amount)
					handled = true
				else:
					push_warning("QuestSystem: Global.add_points() not found, cannot apply '%s'" % token)
		if not handled:
			if sign > 0:
				emit_signal("reward_item_granted", token)
			else:
				emit_signal("spend_item_required", token)


## Grants reward_items on completion. Format: comma-separated "name_amount"
## tokens, e.g. "coins_1,gold_50" - see _apply_points_tokens().
func _grant_rewards(reward_items: String) -> void:
	_apply_points_tokens(reward_items, 1)


## Parses an add_todo cfg value - see file header for the full syntax.
## Accepts two formats, distinguished by whether the string contains a
## "{" anywhere:
##   - No "{" present: the entire (trimmed) string is the activity text,
##     verbatim, with every parameter left at its default. This is the
##     common case and deliberately requires no escaping or syntax at all.
##   - "{" present: parsed as JSON - either a single object, or an array
##     of objects for multiple to-do items from one quest/task. A plain
##     activity string essentially never contains a literal "{", so this
##     is safe to use as the sole discriminator.
## Both forms normalize into the same Array of {"activity": String,
## "params": Dictionary} - _apply_add_todo() doesn't need to know or care
## which format was used.
func _parse_add_todo(raw: String) -> Array:
	var out: Array = []
	if raw == null or raw.strip_edges() == "":
		return out
	var s: String = raw.strip_edges()

	if s.find("{") == -1:
		# Simple format: no parameters possible, nothing to parse.
		out.append({"activity": s, "params": {}})
		return out

	# Complex format: JSON, either one object or an array of objects.
	var parsed = JSON.parse_string(s)
	if parsed == null:
		push_warning("QuestSystem: add_todo contains '{' but is not valid JSON: '%s'" % s)
		return out
	if parsed is Dictionary:
		parsed = [parsed]
	if not parsed is Array:
		push_warning("QuestSystem: add_todo JSON must be an object or an array of objects: '%s'" % s)
		return out

	for entry in parsed:
		if not entry is Dictionary:
			push_warning("QuestSystem: add_todo JSON array entry is not an object, skipped: %s" % str(entry))
			continue
		var activity: String = String(entry.get("activity", "")).strip_edges()
		if activity == "":
			push_warning("QuestSystem: add_todo JSON entry missing 'activity', skipped: %s" % str(entry))
			continue
		var params: Dictionary = {}
		for key in ["repeat", "category", "reward", "due_in_days"]:
			if entry.has(key):
				params[key] = str(entry[key])  # str() so a JSON number (e.g. due_in_days: 3) works the same as a string
		out.append({"activity": activity, "params": params})
	return out


## Applies add_todo on quest/task COMPLETED, creating one ToDoManager item
## per parsed entry. Silently (with a warning) does nothing if the
## ToDoManager autoload isn't present in this project - add_todo is an
## optional enhancement, not a hard dependency of QuestSystem.
func _apply_add_todo(_raw: String) -> void:
	pass  # not used in this game


## Spends spend_on_entry on ACTIVE (quest/task start). Same format as
## reward_items. NOTE: this does not itself enforce that the balance is
## sufficient - pair it with a points_gte start_condition (see
## FactDatabase.eval_condition()) so the quest/task can't even start
## without enough balance; spend_on_entry only performs the deduction
## once entry is already granted.
func _spend_on_entry(spend_on_entry: String) -> void:
	_apply_points_tokens(spend_on_entry, -1)

func _parse_json_array(raw) -> Array:
	if raw is Array: return raw
	if raw is String and raw != "":
		var p = JSON.parse_string(raw)
		if p is Array: return p
	return []

func _parse_json_dict(raw) -> Dictionary:
	if raw is Dictionary: return raw
	if raw is String and raw != "":
		var p = JSON.parse_string(raw)
		if p is Dictionary: return p
	return {}
