extends Node
## Design tokens and theme. Values mirror the Figma "Tokens" variable collection.

const INK := Palette.INK
const PANEL := Palette.PANEL
const PANEL2 := Palette.PANEL2
const LINE := Palette.LINE
const CREAM := Palette.CREAM
const MUTED := Palette.MUTED
const AMBER := Palette.AMBER
const AMBER_DEEP := Palette.AMBER_DEEP
const TEAL := Palette.TEAL
const GREEN := Palette.GREEN
const CORAL := Palette.CORAL
const WOOD := Palette.WOOD
const CLEAR := Palette.CLEAR

var font_display: Font
var font_body: Font
var font_body_bold: Font
var font_mono: Font
var theme: Theme


func _ready() -> void:
	font_display = _make_font("res://assets/fonts/Fredoka.ttf", 0.45)
	font_body = _make_font("res://assets/fonts/Nunito.ttf", 0.0)
	font_body_bold = _make_font("res://assets/fonts/Nunito.ttf", 0.45)
	font_mono = _make_font("res://assets/fonts/ShareTechMono.ttf", 0.0)
	theme = _build_theme()


func _make_font(path: String, embolden: float) -> Font:
	var base := load(path) as Font
	if base == null:
		push_warning("Style: font missing (%s), using fallback" % path)
		return ThemeDB.fallback_font
	var fv := FontVariation.new()
	fv.base_font = base
	fv.variation_embolden = embolden
	return fv


func box(bg: Color, radius: int = 18, border: Color = CLEAR, border_w: int = 0, pad: Vector2 = Vector2(24, 12)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.content_margin_left = pad.x
	sb.content_margin_right = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_bottom = pad.y
	sb.anti_aliasing = true
	return sb


func _build_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font_body
	t.default_font_size = 18

	t.set_color("font_color", "Label", CREAM)

	# Buttons: default is the outlined "secondary" look.
	t.set_stylebox("normal", "Button", box(CLEAR, 20, LINE, 2, Vector2(24, 12)))
	t.set_stylebox("hover", "Button", box(PANEL2, 20, MUTED, 2, Vector2(24, 12)))
	t.set_stylebox("pressed", "Button", box(PANEL, 20, LINE, 2, Vector2(24, 12)))
	t.set_stylebox("disabled", "Button", box(CLEAR, 20, PANEL2, 2, Vector2(24, 12)))
	t.set_stylebox("focus", "Button", box(CLEAR, 20, AMBER, 3, Vector2(24, 12)))
	t.set_font("font", "Button", font_display)
	t.set_font_size("font_size", "Button", 20)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "Button", CREAM)
	t.set_color("font_disabled_color", "Button", MUTED)

	# Primary (amber).
	t.set_type_variation("PrimaryButton", "Button")
	t.set_stylebox("normal", "PrimaryButton", box(AMBER, 20, CLEAR, 0, Vector2(28, 14)))
	t.set_stylebox("hover", "PrimaryButton", box(Color("FFCB78"), 20, CLEAR, 0, Vector2(28, 14)))
	t.set_stylebox("pressed", "PrimaryButton", box(AMBER_DEEP, 20, CLEAR, 0, Vector2(28, 14)))
	t.set_stylebox("disabled", "PrimaryButton", box(LINE, 20, CLEAR, 0, Vector2(28, 14)))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "PrimaryButton", INK)
	t.set_color("font_disabled_color", "PrimaryButton", MUTED)

	# Choice buttons (quiz answers, filled, left aligned).
	t.set_type_variation("ChoiceButton", "Button")
	t.set_stylebox("normal", "ChoiceButton", box(PANEL2, 16, LINE, 1, Vector2(18, 14)))
	t.set_stylebox("hover", "ChoiceButton", box(LINE, 16, MUTED, 1, Vector2(18, 14)))
	t.set_stylebox("pressed", "ChoiceButton", box(PANEL, 16, AMBER, 2, Vector2(18, 14)))
	t.set_stylebox("disabled", "ChoiceButton", box(PANEL2, 16, LINE, 1, Vector2(18, 14)))
	t.set_font("font", "ChoiceButton", font_body_bold)
	t.set_font_size("font_size", "ChoiceButton", 17)
	t.set_color("font_disabled_color", "ChoiceButton", CREAM)

	# Cards.
	t.set_type_variation("Card", "PanelContainer")
	t.set_stylebox("panel", "Card", box(PANEL, 24, LINE, 1, Vector2(24, 20)))
	t.set_stylebox("panel", "Panel", box(PANEL, 24, LINE, 1, Vector2(24, 20)))

	# Text input.
	t.set_stylebox("normal", "LineEdit", box(PANEL2, 16, LINE, 1, Vector2(16, 10)))
	t.set_stylebox("focus", "LineEdit", box(PANEL2, 16, AMBER, 2, Vector2(16, 10)))
	t.set_color("font_color", "LineEdit", CREAM)
	t.set_color("font_placeholder_color", "LineEdit", MUTED)
	t.set_color("caret_color", "LineEdit", AMBER)
	t.set_font_size("font_size", "LineEdit", 20)

	# Progress bars.
	t.set_stylebox("background", "ProgressBar", box(INK, 6, CLEAR, 0, Vector2(0, 0)))
	t.set_stylebox("fill", "ProgressBar", box(TEAL, 6, CLEAR, 0, Vector2(0, 0)))
	t.set_constant("outline_size", "Label", 0)

	# Sliders.
	var track := box(INK, 6, CLEAR, 0, Vector2(0, 0))
	track.content_margin_top = 6
	track.content_margin_bottom = 6
	t.set_stylebox("slider", "HSlider", track)
	t.set_stylebox("grabber_area", "HSlider", box(AMBER, 6, CLEAR, 0, Vector2(0, 0)))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(AMBER, 6, CLEAR, 0, Vector2(0, 0)))
	return t


# ---- small factories used by the screens ------------------------------------------------

func label(text: String, size: int = 18, color: Color = CREAM, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_override("font", font if font != null else font_body)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func display_label(text: String, size: int = 28, color: Color = CREAM) -> Label:
	return label(text, size, color, font_display)


func mono_label(text: String, size: int = 20, color: Color = TEAL) -> Label:
	return label(text, size, color, font_mono)
