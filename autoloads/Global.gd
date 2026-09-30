extends Node
## Minimal stand-in for galene's "Global" autoload. FactDatabase and QuestSystem probe it
## with has_method(); only the points/currency calls are actually implemented here.

signal points_changed(type: String, total: int)

var _points: Dictionary = {}


func current_island() -> String:
	return ""


func get_common(_key: String) -> String:
	return ""


func add_points(type: String, amount: int) -> void:
	_points[type] = int(_points.get(type, 0)) + amount
	points_changed.emit(type, _points[type])


func get_points(type: String) -> int:
	return int(_points.get(type, 0))


func reset() -> void:
	_points.clear()
