class_name Palette
extends RefCounted
## Colour tokens (same values as the Figma "Tokens" collection). Constants so they can
## be used in const expressions and default arguments.

const INK := Color("0F1A2B")
const PANEL := Color("1B2A41")
const PANEL2 := Color("24364F")
const LINE := Color("34486A")
const CREAM := Color("F3EBDD")
const MUTED := Color("9FB0C8")
const AMBER := Color("FFB84D")
const AMBER_DEEP := Color("E8901A")
const TEAL := Color("3FD0C9")
const GREEN := Color("7BD88F")
const CORAL := Color("FF6B5B")
const WOOD := Color("8A5A3B")
const CLEAR := Color(0, 0, 0, 0)


static func fade_ink(a: float) -> Color:
	return Color(INK.r, INK.g, INK.b, a)
