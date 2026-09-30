extends Node
## Loads lesson and question content from res://content.

const COUNTRIES := ["de", "ch", "at", "us", "uk"]

var parts: Array = []
var legal: Dictionary = {}
var qso: Dictionary = {}
var callsigns: Dictionary = {}


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
	var q = _read_json("res://content/qso/scripts.json")
	if q is Dictionary:
		qso = q


func legal_pack(country: String) -> Dictionary:
	return legal.get(country, legal.get("de", {}))


func callsign_book(country: String) -> Dictionary:
	return callsigns.get(country, callsigns.get("de", {}))


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
