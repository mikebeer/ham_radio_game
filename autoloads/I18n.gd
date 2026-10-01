extends Node
## National language support: English, German, Italian, French, Spanish and Latin (UI); lessons in English and German.
##
## UI strings live in content/i18n/ui.json as {"key": {"en": "...", "de": "..."}}.
## Lesson and question content carries the same {"en","de"} shape; use loc() for those.
## (JSON is read at runtime, so no editor import step is needed and it exports cleanly
## once "*.json" is added to the export filter for non-resource files.)

signal locale_changed(locale: String)

const LOCALES := ["en", "de", "it", "fr", "es", "la"]
## Native names for the language picker.
const NAMES := {"en": "English", "de": "Deutsch", "it": "Italiano", "fr": "Français", "es": "Español", "la": "Latina"}
## Lessons and questions exist in these languages; other languages show the English lessons.
const CONTENT_LOCALES := ["en", "de"]
## UI translations made with AI that native speakers have not reviewed yet.
const UNREVIEWED := ["it", "fr", "es", "la"]
const UI_PATH := "res://content/i18n/ui.json"

var locale: String = "en"
var _ui: Dictionary = {}


func _ready() -> void:
	var parsed = _read_json(UI_PATH)
	if parsed is Dictionary:
		_ui = parsed
	var os_lang := OS.get_locale_language()
	if LOCALES.has(os_lang):
		locale = os_lang
	TranslationServer.set_locale(locale)


## Look up a UI string. Extra args are applied with the % operator.
func t(key: String, args: Array = []) -> String:
	var entry = _ui.get(key, null)
	if entry == null:
		push_warning("I18n: missing key '%s'" % key)
		return key
	var s: String = str(entry.get(locale, entry.get("en", key)))
	if args.is_empty():
		return s
	return s % args


## Pick the current language out of a {"en": ..., "de": ...} dictionary.
func loc(v) -> String:
	if v is Dictionary:
		return str(v.get(locale, v.get("en", "")))
	return str(v)


func set_locale(new_locale: String) -> void:
	if new_locale == locale or not LOCALES.has(new_locale):
		return
	locale = new_locale
	TranslationServer.set_locale(new_locale)
	locale_changed.emit(new_locale)


func has_key(key: String) -> bool:
	return _ui.has(key)


func _read_json(path: String):
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("I18n: cannot open %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())
