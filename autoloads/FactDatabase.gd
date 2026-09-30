# Copied from mikebeer/galene (mvp/0.5/autoloads). Only change: removed the server sync call in set_fact().
# =============================================================================
# FactDatabase.gd  —  Autoload singleton — Godot 4.6
#
# Three complementary fact systems, all in one autoload:
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ 1. SIMPLE FACTS  (original)                                             │
# │    Key-value pairs: string key → bool/int/float/String                  │
# │    set_fact("player_health", 80)                                         │
# │    get_fact("player_health")   → 80                                      │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ 2. PREDICATE STORE  (new)                                               │
# │    Relational n-ary predicates: functor + argument tuple                 │
# │    assert_pred("has",   "npc_guard", "lantern")                          │
# │    assert_pred("color", "flower",    "blue")                             │
# │    query_pred("has", "npc_guard", "?Item")  → [{"?Item":"lantern"}]     │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ 3. PROLOG ENGINE  (new)                                                  │
# │    Horn-clause knowledge base with unification and backward chaining.    │
# │    assert_clause("parent(?X,?Y) :- father(?X,?Y)")                      │
# │    assert_clause("father(tom,bob)")                                       │
# │    prolog_query("parent(tom,?Who)")  → [{"?Who":"bob"}, ...]            │
# └─────────────────────────────────────────────────────────────────────────┘
#
# Quest condition operators (all three systems unified):
#   Simple:    eq  neq  gt  gte  lt  lte  has  not
#   Predicate: pred_true  pred_false
#   Prolog:    prolog_true  prolog_false
#
# Condition examples:
#   {"op":"pred_true",   "functor":"has",    "args":["npc_guard","lantern"]}
#   {"op":"pred_false",  "functor":"color",  "args":["flower","red"]}
#   {"op":"prolog_true", "goal":"enemy(?X), armed(?X)"}
#   {"op":"prolog_false","goal":"defeated(shade_keeper)"}
#
# CHANGELOG (type-safety fixes):
#   FIX 1  New helper _is_truthy(): replaces the chained `!= null / false / 0 / ""`
#          comparisons that crashed with "Invalid operands 'bool' and 'int'".
#   FIX 2  "has" / "not" operators now use _is_truthy().
#   FIX 3  Prolog bridge simple_fact/1 now uses _is_truthy() (same crash pattern).
#   FIX 4  New helper _values_equal(): "eq" / "neq" no longer throw when the
#          fact type and the condition value type differ (e.g. true vs 1, 1 vs 1.0).
# =============================================================================
extends Node

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------
signal fact_changed(key: String, old_value, new_value)
signal fact_removed(key: String)
signal pred_asserted(functor: String, args: Array)
signal pred_retracted(functor: String, args: Array)
signal clause_asserted(head: String)

# ===========================================================================
# SYSTEM 1 — Simple key/value facts
# ===========================================================================

var _facts : Dictionary = {}

# ── Write ────────────────────────────────────────────────────────────────────

func set_fact(key: String, value) -> void:
	var old = _facts.get(key, null)
	_facts[key] = value
	if old != value:
		emit_signal("fact_changed", key, old, value)
	# (galene server sync via Global.http_call removed for this standalone game)

func increment_fact(key: String, amount: int = 1) -> void:
	set_fact(key, _facts.get(key, 0) + amount)

func remove_fact(key: String) -> void:
	if _facts.has(key):
		_facts.erase(key)
		emit_signal("fact_removed", key)

func clear_all() -> void:
	_facts.clear()
	_predicates.clear()
	_clauses.clear()

# ── Read ─────────────────────────────────────────────────────────────────────

func get_fact(key: String, default = null):
	return _facts.get(key, default)

func has_fact(key: String) -> bool:
	return _facts.has(key)

func snapshot() -> Dictionary:
	return {
		"facts":      _facts.duplicate(true),
		"predicates": _snapshot_predicates(),
		"clauses":    _snapshot_clauses(),
	}

func restore(snap) -> void:
	# Accept both old format (plain dict) and new format (nested dict)
	if snap is Dictionary and snap.has("facts"):
		_facts = snap["facts"].duplicate(true)
		if snap.has("predicates"): _restore_predicates(snap["predicates"])
		if snap.has("clauses"):    _restore_clauses(snap["clauses"])
	else:
		_facts = (snap as Dictionary).duplicate(true)

# ── Dump ─────────────────────────────────────────────────────────────────────

func dump() -> void:
	print("=== FactDatabase — Simple Facts ===")
	for k in _facts:
		print("  %s = %s" % [k, str(_facts[k])])
	print("=== Predicates ===")
	for f in _predicates:
		for args in _predicates[f]:
			print("  %s(%s)" % [f, ", ".join(PackedStringArray(args))])
	print("=== Clauses ===")
	for c in _clauses:
		print("  %s" % c.get("raw", "?"))
	print("===================================")


# ===========================================================================
# SYSTEM 2 — Predicate store
#
# A predicate is identified by its functor name and arity (argument count).
# Stored as:  _predicates[functor] = [ [arg0,arg1,...], ... ]
#
# Terms:
#   Atom    — any String that does NOT start with "?"   e.g. "npc_guard"
#   Variable— String starting with "?"                  e.g. "?Item"
#   "_"     — anonymous variable, matches anything, never bound
# ===========================================================================

var _predicates : Dictionary = {}   # functor -> Array of Array[String]

# ── Assert / Retract ─────────────────────────────────────────────────────────

## Add a ground predicate fact (all args must be atoms, not variables).
## assert_pred("has", "npc_guard", "lantern")
## assert_pred("color", "sky", "blue")
func assert_pred(functor: String, arg0 = null, arg1 = null, arg2 = null,
				 arg3 = null, arg4 = null) -> void:
	var args = _collect_args(arg0, arg1, arg2, arg3, arg4)
	if not _predicates.has(functor):
		_predicates[functor] = []
	# Avoid duplicates
	for existing in _predicates[functor]:
		if existing == args:
			return
	_predicates[functor].append(args)
	emit_signal("pred_asserted", functor, args)

## Remove a specific ground predicate fact.
func retract_pred(functor: String, arg0 = null, arg1 = null, arg2 = null,
				  arg3 = null, arg4 = null) -> bool:
	var args = _collect_args(arg0, arg1, arg2, arg3, arg4)
	if not _predicates.has(functor):
		return false
	var before = _predicates[functor].size()
	_predicates[functor] = _predicates[functor].filter(func(a): return a != args)
	if _predicates[functor].size() < before:
		emit_signal("pred_retracted", functor, args)
		return true
	return false

## Remove ALL facts for a functor (any arity).
func retract_all_pred(functor: String) -> void:
	_predicates.erase(functor)

# ── Query ────────────────────────────────────────────────────────────────────

## Check whether a specific ground predicate is asserted.
## check_pred("has", "npc_guard", "lantern")  →  true / false
func check_pred(functor: String, arg0 = null, arg1 = null, arg2 = null,
				arg3 = null, arg4 = null) -> bool:
	var args = _collect_args(arg0, arg1, arg2, arg3, arg4)
	if not _predicates.has(functor):
		return false
	return args in _predicates[functor]

## Pattern-match query.  Use "?VarName" for variables, "_" for anonymous.
## Returns Array of binding Dictionaries — one per solution.
##
## Examples:
##   query_pred("has", "npc_guard", "?Item")
##   → [{"?Item": "lantern"}, {"?Item": "sword"}]
##
##   query_pred("color", "?Obj", "blue")
##   → [{"?Obj": "sky"}, {"?Obj": "flower"}]
##
##   query_pred("has", "_", "_")   →  [{}, {}, ...]  (one per matching row)
func query_pred(functor: String, arg0 = null, arg1 = null, arg2 = null,
				arg3 = null, arg4 = null) -> Array:
	var pattern = _collect_args(arg0, arg1, arg2, arg3, arg4)
	var results : Array = []
	if not _predicates.has(functor):
		return results
	for row in _predicates[functor]:
		if row.size() != pattern.size():
			continue
		var bindings = _unify_row(pattern, row)
		if bindings != null:
			results.append(bindings)
	return results

## Returns true if query_pred has at least one solution.
func pred_holds(functor: String, arg0 = null, arg1 = null, arg2 = null,
				arg3 = null, arg4 = null) -> bool:
	return query_pred(functor, arg0, arg1, arg2, arg3, arg4).size() > 0

## List all ground facts for a functor as Array of Arrays.
func get_all_pred(functor: String) -> Array:
	return _predicates.get(functor, []).duplicate(true)


# ===========================================================================
# SYSTEM 3 — Prolog engine
#
# A minimal but complete Prolog interpreter:
#   • Horn clauses: head :- body_goal_1, body_goal_2, ...
#   • Facts (unit clauses): head.   (no body)
#   • Variables: atoms starting with "?"  e.g. ?X, ?Who, ?Item
#   • Anonymous variable: "_"  (always unifies, never binds)
#   • Unification with occurs-check
#   • Depth-first backward chaining with backtracking
#   • Built-in goals: true, fail, not(Goal), eq(?X, atom), neq(?X, atom)
#   • Integration: simple_fact(Key) — true if set_fact(Key, truthy) is set
#                  pred(Functor, Arg…) — bridges to predicate store
#
# Clause syntax (parsed from strings):
#   "functor(arg1, arg2)"           — fact
#   "head(X) :- body1(X), body2"   — rule
#
# Term syntax:
#   atom     — lowercase or quoted string with no "?"  e.g. "tom", "npc_guard"
#   variable — starts with "?"                          e.g. "?X", "?Who"
#   compound — functor(arg, arg, ...)
# ===========================================================================

var _clauses : Array = []   # Array of {head: Term, body: Array[Term], raw: String}

# Parsing limit guards
const _MAX_DEPTH   := 64    # max recursion depth
const _MAX_RESULTS := 256   # max solutions returned

# ── Assert clauses ────────────────────────────────────────────────────────────

## Assert a Horn clause from a string.
##   assert_clause("has(npc_guard, lantern)")
##   assert_clause("armed(?X) :- has(?X, sword)")
##   assert_clause("enemy(?X) :- goblin(?X)")
##   assert_clause("enemy(?X) :- orc(?X)")
func assert_clause(clause_str: String) -> void:
	var parsed = _parse_clause(clause_str.strip_edges())
	if parsed == null or parsed.is_empty():
		push_error("FactDatabase Prolog: cannot parse clause '%s'" % clause_str)
		return
	parsed["raw"] = clause_str
	_clauses.append(parsed)
	emit_signal("clause_asserted", clause_str)

## Assert multiple clauses at once.
func assert_clauses(clause_array: Array) -> void:
	for c in clause_array: assert_clause(c)

## Remove all clauses whose head functor matches.
func retract_clauses(functor: String) -> void:
	_clauses = _clauses.filter(func(c):
		return c["head"].get("functor", "") != functor)

## Remove all clauses.
func retract_all_clauses() -> void:
	_clauses.clear()

# ── Query ────────────────────────────────────────────────────────────────────

## Run a Prolog query.  Returns Array of binding Dictionaries (one per solution).
## Variables in the query that are bound in a solution appear as keys.
##
## Examples:
##   prolog_query("parent(tom, ?Who)")
##   → [{"?Who": "bob"}, {"?Who": "liz"}]
##
##   prolog_query("has(?Who, sword), enemy(?Who)")
##   → [{"?Who": "orc_chief"}]
##
##   prolog_query("simple_fact(player_has_map)")
##   → [{}]   if that fact is set, else []
func prolog_query(goal_str: String) -> Array:
	var goals = _parse_goals(goal_str)
	if goals == null or goals.is_empty():
		push_error("FactDatabase Prolog: cannot parse goal '%s'" % goal_str)
		return []
	var results : Array = []
	_solve(goals, {}, 0, results)
	return results

## Returns true if the query has at least one solution.
func prolog_holds(goal_str: String) -> bool:
	return prolog_query(goal_str).size() > 0

## Convenience: query and return first solution's bindings, or null.
func prolog_first(goal_str: String) -> Dictionary:
	var r = prolog_query(goal_str)
	return r[0] if not r.is_empty() else {}


# ===========================================================================
# Unified condition evaluation  (used by QuestSystem)
# ===========================================================================

## Evaluate one condition dict.  Supports all three systems.
func eval_condition(cond: Dictionary) -> bool:
	if not cond.has("op"):
		push_warning("FactDatabase: condition missing 'op': %s" % str(cond))
		return false
	var op : String = cond["op"]

	match op:
		# ── Simple facts ───────────────────────────────────────────────────
		# FIX 2: "has" / "not" used to be:
		#     f != null and f != false and f != 0 and f != ""
		# In Godot 4 comparing Variants of incompatible types with != raises
		# "Invalid operands 'bool' and 'int' in operator '!='" at runtime.
		# _is_truthy() checks the type first, so no mixed-type comparison occurs.
		"has":
			return _is_truthy(_facts.get(cond.get("key",""), null))
		"not":
			return not _is_truthy(_facts.get(cond.get("key",""), null))
		# FIX 4: eq / neq go through _values_equal() so a bool fact compared
		# with an int/float condition value (or 1 vs 1.0 from JSON) can't throw.
		"eq":
			return _values_equal(_facts.get(cond.get("key",""), null), cond.get("value"))
		"neq":
			return not _values_equal(_facts.get(cond.get("key",""), null), cond.get("value"))
		"gt":
			return _to_num(_facts.get(cond.get("key",""), null)) > _to_num(cond.get("value"))
		"gte":
			return _to_num(_facts.get(cond.get("key",""), null)) >= _to_num(cond.get("value"))
		"lt":
			return _to_num(_facts.get(cond.get("key",""), null)) < _to_num(cond.get("value"))
		"lte":
			return _to_num(_facts.get(cond.get("key",""), null)) <= _to_num(cond.get("value"))

		# ── Points / currency (coins, energy, diamonds, ...) ────────────────
		# {"op":"points_gte", "type":"energy", "value":1}   - at least 1 energy
		# {"op":"points_gt",  "type":"energy", "value":1}   - more than 1 energy
		# Reads live via Global.get_points(type) - not a fact, so nothing
		# needs to call set_fact() to keep this in sync.
		"points_eq":
			return _get_points(cond.get("type","")) == _to_num(cond.get("value"))
		"points_neq":
			return _get_points(cond.get("type","")) != _to_num(cond.get("value"))
		"points_gt":
			return _get_points(cond.get("type","")) > _to_num(cond.get("value"))
		"points_gte":
			return _get_points(cond.get("type","")) >= _to_num(cond.get("value"))
		"points_lt":
			return _get_points(cond.get("type","")) < _to_num(cond.get("value"))
		"points_lte":
			return _get_points(cond.get("type","")) <= _to_num(cond.get("value"))

		# ── Predicate store ────────────────────────────────────────────────
		# {"op":"pred_true",  "functor":"has", "args":["npc_guard","lantern"]}
		# {"op":"pred_false", "functor":"color","args":["flower","red"]}
		"pred_true":
			var functor : String = cond.get("functor", "")
			var args    : Array  = cond.get("args", [])
			return _pred_holds_array(functor, args)
		"pred_false":
			var functor : String = cond.get("functor", "")
			var args    : Array  = cond.get("args", [])
			return not _pred_holds_array(functor, args)

		# ── Prolog engine ──────────────────────────────────────────────────
		# {"op":"prolog_true",  "goal":"enemy(?X), armed(?X)"}
		# {"op":"prolog_false", "goal":"defeated(shade_keeper)"}
		"prolog_true":
			return prolog_holds(cond.get("goal", ""))
		"prolog_false":
			return not prolog_holds(cond.get("goal", ""))

		_:
			push_warning("FactDatabase: Unknown operator '%s'" % op)
			return false


## Evaluate a list of conditions — ALL must pass (AND).
func eval_conditions(conditions: Array) -> bool:
	for cond in conditions:
		if not eval_condition(cond):
			return false
	return true

## Evaluate a list of conditions — ANY must pass (OR).
func eval_conditions_or(conditions: Array) -> bool:
	for cond in conditions:
		if eval_condition(cond):
			return true
	return false


# ===========================================================================
# Private — Type-safe value helpers  (FIX 1 and FIX 4)
# ===========================================================================

## FIX 1: Type-safe truthiness check for a fact value.
## A value counts as "set" if it is non-null, non-false, non-zero and non-empty.
## We branch on typeof() first so we never compare a bool against an int (or an
## int against a String), which is what raised
## "Invalid operands 'bool' and 'int' in operator '!='" in GDScript 4.
## Any other type (Array, Dictionary, Vector2, ...) counts as truthy.
func _is_truthy(v) -> bool:
	match typeof(v):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING, TYPE_STRING_NAME:
			return v != ""
		_:
			return true


## FIX 4: Type-safe equality for the eq / neq operators.
##   • Both numeric-like (bool/int/float): compared as floats, so
##     true == 1, and 1 == 1.0 (JSON delivers numbers as float).
##   • Same type otherwise: normal ==.
##   • Different, non-numeric types: not equal (no exception).
func _values_equal(a, b) -> bool:
	var ta := typeof(a)
	var tb := typeof(b)
	var a_num : bool = ta == TYPE_BOOL or ta == TYPE_INT or ta == TYPE_FLOAT
	var b_num : bool = tb == TYPE_BOOL or tb == TYPE_INT or tb == TYPE_FLOAT
	if a_num and b_num:
		return is_equal_approx(_to_num(a), _to_num(b))
	if ta == tb:
		return a == b
	# String vs StringName should still compare equal
	if (ta == TYPE_STRING or ta == TYPE_STRING_NAME) and (tb == TYPE_STRING or tb == TYPE_STRING_NAME):
		return str(a) == str(b)
	return false


# ===========================================================================
# Private — Predicate helpers
# ===========================================================================

func _collect_args(a0, a1, a2, a3, a4) -> Array:
	var args = []
	for v in [a0, a1, a2, a3, a4]:
		if v == null: break
		args.append(str(v))
	return args

func _unify_row(pattern: Array, row: Array):
	# Returns binding dict or null on failure
	var bindings : Dictionary = {}
	for i in pattern.size():
		var p = pattern[i]
		var r = row[i]
		if p == "_":
			continue
		elif p.begins_with("?"):
			if bindings.has(p):
				if bindings[p] != r: return null
			else:
				bindings[p] = r
		else:
			if p != r: return null
	return bindings

func _pred_holds_array(functor: String, args: Array) -> bool:
	if not _predicates.has(functor): return false
	for row in _predicates[functor]:
		if row.size() != args.size(): continue
		var ok = true
		for i in args.size():
			if args[i] != "_" and not args[i].begins_with("?") and args[i] != row[i]:
				ok = false; break
		if ok: return true
	return false

func _snapshot_predicates() -> Dictionary:
	var snap = {}
	for f in _predicates:
		snap[f] = _predicates[f].duplicate(true)
	return snap

func _restore_predicates(snap: Dictionary) -> void:
	_predicates.clear()
	for f in snap:
		_predicates[f] = snap[f].duplicate(true)

func _snapshot_clauses() -> Array:
	var snap = []
	for c in _clauses:
		snap.append(c.get("raw", ""))
	return snap

func _restore_clauses(snap: Array) -> void:
	_clauses.clear()
	for raw in snap:
		assert_clause(raw)


# ===========================================================================
# Private — Prolog engine
# ===========================================================================

# ── Term representation ───────────────────────────────────────────────────────
# An atom:     {"type":"atom",     "name":"tom"}
# A variable:  {"type":"var",      "name":"?X"}
# A compound:  {"type":"compound", "functor":"has", "args":[Term, Term, ...]}
# We use plain Strings for atoms internally in unification for speed.

func _atom(name: String) -> Dictionary:
	return {"type":"atom","name":name}

func _var(name: String) -> Dictionary:
	return {"type":"var","name":name}

func _compound(functor: String, args: Array) -> Dictionary:
	return {"type":"compound","functor":functor,"args":args}

# ── Solve (backward chaining) ─────────────────────────────────────────────────

func _solve(goals: Array, env: Dictionary, depth: int, results: Array) -> void:
	if results.size() >= _MAX_RESULTS or depth > _MAX_DEPTH:
		return

	if goals.is_empty():
		# All goals satisfied — record this solution
		# Collect only original query variable bindings (walk env)
		var sol : Dictionary = {}
		for k in env:
			sol[k] = _walk_str(_deref({"type":"var","name":k}, env))
		results.append(sol)
		return

	var goal  = goals[0]
	var rest  = goals.slice(1)

	# ── Built-in goals ────────────────────────────────────────────────────────
	var gf = _term_functor(goal)

	if gf == "true/0":
		_solve(rest, env, depth + 1, results)
		return

	if gf == "fail/0":
		return   # backtrack

	if gf == "not/1":
		var inner = goal["args"][0]
		var sub_results : Array = []
		_solve([inner] + rest.slice(0, 0), env, depth + 1, sub_results)
		# not(G) succeeds if G has no solutions
		var neg_goals : Array = [inner]
		var neg_res : Array = []
		_solve(neg_goals, env, depth + 1, neg_res)
		if neg_res.is_empty():
			_solve(rest, env, depth + 1, results)
		return

	if gf == "eq/2":
		var a = _deref(goal["args"][0], env)
		var b = _deref(goal["args"][1], env)
		var new_env = _unify_terms(a, b, env)
		if new_env != null:
			_solve(rest, new_env, depth + 1, results)
		return

	if gf == "neq/2":
		var a = _deref(goal["args"][0], env)
		var b = _deref(goal["args"][1], env)
		var test_env = _unify_terms(a, b, env.duplicate())
		if test_env == null:   # unification fails → neq succeeds
			_solve(rest, env, depth + 1, results)
		return

	# simple_fact(Key) — bridges to System 1
	# FIX 3: previously used the same `val != null and val != false and val != 0
	# and val != ""` chain as "has", which crashes on bool/int mixes. Now uses
	# the type-safe _is_truthy().
	if gf == "simple_fact/1":
		var key_term = _deref(goal["args"][0], env)
		var key_str  = _walk_str(key_term)
		if _is_truthy(_facts.get(key_str, null)):
			_solve(rest, env, depth + 1, results)
		return

	# pred(Functor, Arg, ...) — bridges to System 2
	if goal.get("type") == "compound" and goal.get("functor") == "pred":
		var pargs = goal.get("args", [])
		if pargs.size() >= 1:
			var fname = _walk_str(_deref(pargs[0], env))
			var pquery_args = []
			for i in range(1, pargs.size()):
				pquery_args.append(_walk_str(_deref(pargs[i], env)))
			if _predicates.has(fname):
				for row in _predicates[fname]:
					if row.size() != pquery_args.size(): continue
					var new_env = env.duplicate()
					var ok = true
					for i in row.size():
						var pat = pquery_args[i]
						if pat == "_": continue
						elif pat.begins_with("?"):
							if new_env.has(pat):
								if new_env[pat] != row[i]: ok = false; break
							else:
								new_env[pat] = row[i]
						else:
							if pat != row[i]: ok = false; break
					if ok:
						_solve(rest, new_env, depth + 1, results)
		return

	# ── User-defined clauses ──────────────────────────────────────────────────
	for clause in _clauses:
		var head  = clause["head"]
		var body  = clause["body"]
		# Rename variables to avoid clashes
		var fresh = _rename_clause(head, body, depth)
		head  = fresh[0]
		body  = fresh[1]
		var new_env = _unify_terms(goal, head, env.duplicate())
		if new_env != null:
			_solve(body + rest, new_env, depth + 1, results)

# ── Unification ───────────────────────────────────────────────────────────────

func _deref(term: Dictionary, env: Dictionary) -> Dictionary:
	if term.get("type") == "var":
		var name = term["name"]
		if env.has(name):
			var bound = env[name]
			if bound is Dictionary:
				return _deref(bound, env)
			else:
				# Bound to a plain string atom
				return _atom(str(bound))
	return term

func _unify_terms(a: Dictionary, b: Dictionary, env: Dictionary):
	a = _deref(a, env)
	b = _deref(b, env)

	# Both atoms
	if a.get("type") == "atom" and b.get("type") == "atom":
		return env if a["name"] == b["name"] else null

	# Left is variable
	if a.get("type") == "var":
		env[a["name"]] = b
		return env

	# Right is variable
	if b.get("type") == "var":
		env[b["name"]] = a
		return env

	# Both compounds
	if a.get("type") == "compound" and b.get("type") == "compound":
		if a["functor"] != b["functor"]: return null
		if a["args"].size() != b["args"].size(): return null
		for i in a["args"].size():
			env = _unify_terms(a["args"][i], b["args"][i], env)
			if env == null: return null
		return env

	return null

func _walk_str(term: Dictionary) -> String:
	if term.get("type") == "atom":
		return term["name"]
	if term.get("type") == "var":
		return term["name"]
	if term.get("type") == "compound":
		var arg_strs = []
		for a in term.get("args", []):
			arg_strs.append(_walk_str(a))
		return "%s(%s)" % [term["functor"], ", ".join(PackedStringArray(arg_strs))]
	return str(term)

func _term_functor(term: Dictionary) -> String:
	match term.get("type"):
		"atom":     return "%s/0" % term["name"]
		"var":      return "?/%s" % term["name"]
		"compound": return "%s/%d" % [term["functor"], term["args"].size()]
	return "?"

func _rename_clause(head: Dictionary, body: Array, depth: int) -> Array:
	var suffix = "_%d" % depth
	var renamed_head  = _rename_term(head, suffix)
	var renamed_body  = []
	for g in body:
		renamed_body.append(_rename_term(g, suffix))
	return [renamed_head, renamed_body]

func _rename_term(term: Dictionary, suffix: String) -> Dictionary:
	match term.get("type"):
		"var":
			return _var(term["name"] + suffix)
		"compound":
			var new_args = []
			for a in term.get("args", []):
				new_args.append(_rename_term(a, suffix))
			return _compound(term["functor"], new_args)
		_:
			return term.duplicate()


# ===========================================================================
# Private — Parser
# ===========================================================================
# Parses: "head :- body_goal, body_goal2"
# Returns: {head: Term, body: [Term, ...]} or null

func _parse_clause(s: String):
	var parts = s.split(":-", false, 1)
	var head_str = parts[0].strip_edges()
	var body_str = parts[1].strip_edges() if parts.size() > 1 else ""
	var head = _parse_term(head_str)
	if head == null or head.is_empty():
		return {}
	var body : Array = []
	if body_str != "":
		body = _parse_goals(body_str)
		# Empty result from non-empty body string means parse error
		if body == null or (body.is_empty() and not body_str.strip_edges().is_empty()): return {}
	return {"head": head, "body": body}

func _parse_goals(s: String) -> Array:
	# Split by top-level commas (not inside parentheses)
	var goals  : Array = []
	var depth  : int   = 0
	var start  : int   = 0
	for i in s.length():
		var c = s[i]
		if c == "(": depth += 1
		elif c == ")": depth -= 1
		elif c == "," and depth == 0:
			var sub = s.substr(start, i - start).strip_edges()
			if sub != "":
				var t = _parse_term(sub)
				if t == null: return []
				goals.append(t)
			start = i + 1
	var last = s.substr(start).strip_edges()
	if last != "":
		var t = _parse_term(last)
		if t.is_empty(): return []
		goals.append(t)
	return goals

func _parse_term(s: String):
	s = s.strip_edges()
	if s.is_empty(): return {}

	# Variable
	if s.begins_with("?") or s == "_":
		return _var(s)

	# Compound: has opening paren but not just a quoted atom
	var paren = s.find("(")
	if paren > 0 and s.ends_with(")"):
		var functor  = s.substr(0, paren).strip_edges()
		var args_str = s.substr(paren + 1, s.length() - paren - 2)
		var args_parsed = _parse_arg_list(args_str)
		if args_parsed == null or args_parsed.is_empty(): return {}
		return _compound(functor, args_parsed)

	# Atom
	return _atom(s)

func _parse_arg_list(s: String):
	if s.strip_edges().is_empty(): return []
	var args  : Array = []
	var depth : int   = 0
	var start : int   = 0
	for i in s.length():
		var c = s[i]
		if c == "(": depth += 1
		elif c == ")": depth -= 1
		elif c == "," and depth == 0:
			var sub = s.substr(start, i - start).strip_edges()
			var t = _parse_term(sub)
			if t.is_empty(): return []
			args.append(t)
			start = i + 1
	var last = s.substr(start).strip_edges()
	if last != "":
		var t = _parse_term(last)
		if t.is_empty(): return []
		args.append(t)
	return args

# ── Numeric helper ────────────────────────────────────────────────────────────

func _to_num(v) -> float:
	if v == null:   return 0.0
	if v is bool:   return 1.0 if v else 0.0
	if v is int or v is float: return float(v)
	if v is String: return float(v)
	return 0.0


## Reads a points/currency balance via the Global autoload's own
## get_points(type) -> int. Returns 0.0 if Global isn't present, the type
## doesn't exist yet, or the type is empty - matching how a missing fact
## reads as 0 for the existing gt/gte/lt/lte ops.
func _get_points(type: String) -> float:
	if type == "":
		print("DEBUG _get_points: type is empty string")
		return 0.0
	if typeof(Global) == TYPE_NIL:
		print("DEBUG _get_points('%s'): Global is TYPE_NIL" % type)
		return 0.0
	if not Global.has_method("get_points"):
		print("DEBUG _get_points('%s'): Global has no method 'get_points'" % type)
		return 0.0
	var raw = Global.get_points(type)
	print("DEBUG _get_points('%s'): Global.get_points() returned %s (type %s)" % [type, raw, typeof(raw)])
	return _to_num(raw)


## Extracts the chapter id prefix from a fact key ("gra.beach_done" -> "gra").
## Returns "" if the key has no "." - shouldn't happen given the project's
## <chapter>.<description> convention (see general_rules.txt), but this
## fails safe rather than crashing on a malformed key.      

func _chapter_id_from_key(key: String) -> String:
	var dot := key.find(".")
	if dot == -1:
		return ""
	return key.substr(0, dot)
