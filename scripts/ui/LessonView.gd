class_name LessonView
extends Control
## One lesson card: title, optional illustration (50ohm drawing or photo on a light panel), body text
## and an optional tip. Scrolls when the text is longer than the space.

const IMG_DIR := "res://assets/course/"
const CREDIT := "50ohm.de, DARC e.V., CC BY 4.0"


## card: {"t": L, "b": L, "tip": L?, "img": "d123"?}; size = area available.
func show_card(card: Dictionary, area: Vector2, body_size: int = 18) -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = area
	size = area
	var sc := ScrollContainer.new()
	sc.size = area
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(sc)
	var w := area.x - 18.0
	var box := VBoxContainer.new()
	box.custom_minimum_size.x = w
	box.add_theme_constant_override("separation", 12)
	sc.add_child(box)
	box.add_child(_wrap(Style.label(I18n.loc(card.get("t", "")), 30, Palette.CREAM, Style.font_display), w))
	var img: String = str(card.get("img", ""))
	var path := IMG_DIR + img + ".png"
	if img != "" and ResourceLoader.exists(path):
		var holder := Panel.new()
		holder.custom_minimum_size = Vector2(w, 176)
		holder.add_theme_stylebox_override("panel", Style.box(Palette.CREAM, 16))
		var tr := TextureRect.new()
		tr.texture = load(path)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.position = Vector2(10, 8)
		tr.size = Vector2(w - 20, 160)
		holder.add_child(tr)
		box.add_child(holder)
	var body := I18n.loc(card.get("b", ""))
	for para in body.split("\n\n"):
		box.add_child(_wrap(Style.label(para.strip_edges(), body_size, Palette.MUTED), w))
	var tip = card.get("tip", null)
	if tip != null and I18n.loc(tip) != "":
		var pc := PanelContainer.new()
		pc.add_theme_stylebox_override("panel", Style.box(Palette.PANEL2, 14, Palette.AMBER_DEEP, 2, Vector2(12, 10)))
		pc.add_child(_wrap(Style.label(I18n.loc(tip), body_size - 2, Palette.AMBER), w - 28))
		box.add_child(pc)
	if img != "" and ResourceLoader.exists(path):
		box.add_child(_wrap(Style.label(CREDIT, 11, Palette.MUTED), w))


func _wrap(l: Label, w: float) -> Label:
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = w
	return l
