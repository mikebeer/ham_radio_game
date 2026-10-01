extends Node
## Loads lesson and question content from res://content.

const COUNTRIES := ["de", "ch", "at", "us", "uk"]

var parts: Array = []
var legal: Dictionary = {}
var qso: Dictionary = {}
var callsigns: Dictionary = {}
var library: Array = []


func _ready() -> void:
	var p = _read_json("res://content/tech/parts.json")
	if p is Array:
		parts = p
	for c in COUNTRIES:
		var pack = _read_json("res://content/legal/%s.json" % c)
		if pack is Dictionary:
			legal[c] = pack
	for c in COUNTRIES:
		var cs = _read_json("res://content/callsigns/%s.json" % c)
		if cs is Dictionary:
			callsigns[c] = cs
	var lib = _read_json("res://content/library.json")
	if lib is Dictionary:
		library = lib.get("entries", [])
	var q = _read_json("res://content/qso/scripts.json")
	if q is Dictionary:
		qso = q


func library_entry(id: String) -> Dictionary:
	for e in library:
		if e.get("id", "") == id:
			return e
	return {}


## Categories in the order they first appear in a fixed list, only those that have entries.
func library_categories() -> Array:
	var out: Array = []
	for c in ["modes", "qcodes", "operating", "equipment", "antennas", "propagation", "electronics", "rules", "learning"]:
		for e in library:
			if e.get("cat", "") == c:
				out.append(c)
				break
	return out


func legal_pack(country: String) -> Dictionary:
	return legal.get(country, legal.get("de", {}))


func callsign_book(country: String) -> Dictionary:
	return callsigns.get(country, callsigns.get("de", {}))


## Lesson and questions of a part for a level (1 = basic, 2/3 = deeper tiers).
func part_tier(id: String, level: int) -> Dictionary:
	var p := part(id)
	var cc := str(Game.profile.get("country", ""))
	var over: Dictionary = (p.get("country_tiers", {}) as Dictionary).get(cc, {})
	if over.has(str(level)):
		var d: Dictionary = (over[str(level)] as Dictionary).duplicate()
		d["id"] = id
		return d
	if level <= 1:
		return p
	return (p.get("tiers", {}) as Dictionary).get(str(level), p)


func qso_steps(level: int) -> Array:
	var cc := str(Game.profile.get("country", ""))
	var over: Dictionary = (qso.get("country_levels", {}) as Dictionary).get(cc, {})
	if over.has(str(level)):
		return (over[str(level)] as Dictionary).get("steps", [])
	if level <= 1:
		return qso.get("steps", [])
	return (qso.get("levels", {}) as Dictionary).get(str(level), {}).get("steps", qso.get("steps", []))


func part(id: String) -> Dictionary:
	for p in parts:
		if p.get("id", "") == id:
			return p
	return {}


func _read_json(path: String):
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Content: cannot open %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())
