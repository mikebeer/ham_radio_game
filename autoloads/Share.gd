extends CanvasLayer
## "I play CQ Quest" sharing. Captures the current screen, then offers social buttons.
## Social sites only accept text + link from apps, so the screenshot is saved for the player
## to attach; on web builds the browser's share sheet can attach it directly.

const URL := "https://github.com/mikebeer/ham_radio_game"

var _root: Control
var _image: Image
var _text_edit: TextEdit
var _saved_path := ""


func _ready() -> void:
	layer = 90


func open() -> void:
	if _root != null:
		return
	# capture first, before the overlay is drawn
	var tex := get_viewport().get_texture()
	_image = tex.get_image() if tex != null else null
	_saved_path = ""
	_build()


func close() -> void:
	if _root:
		_root.queue_free()
		_root = null


func _message() -> String:
	return I18n.t("share.text", [Game.parts_owned()])


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.theme = Style.theme
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)
	var card := Panel.new()
	card.position = Vector2(200, 60)
	card.size = Vector2(880, 600)
	_root.add_child(card)
	_label(I18n.t("share.title"), Vector2(236, 80), 30, Palette.CREAM, Style.font_display)

	# preview
	var prev := Panel.new()
	prev.position = Vector2(236, 140)
	prev.size = Vector2(384, 216)
	prev.add_theme_stylebox_override("panel", Style.box(Palette.INK, 12, Palette.LINE, 1))
	_root.add_child(prev)
	if _image != null:
		var tr := TextureRect.new()
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.texture = ImageTexture.create_from_image(_image)
		tr.position = Vector2(240, 144)
		tr.size = Vector2(376, 208)
		_root.add_child(tr)

	# text
	_text_edit = TextEdit.new()
	_text_edit.position = Vector2(644, 140)
	_text_edit.size = Vector2(404, 216)
	_text_edit.text = _message()
	_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_root.add_child(_text_edit)

	# social buttons
	var nets := [
		["X", "https://twitter.com/intent/tweet?text=%s&url=%s"],
		["Bluesky", "https://bsky.app/intent/compose?text=%s%%20%s"],
		["Facebook", "https://www.facebook.com/sharer/sharer.php?u=%2$s"],
		["LinkedIn", "https://www.linkedin.com/sharing/share-offsite/?url=%2$s"],
		["WhatsApp", "https://wa.me/?text=%s%%20%s"],
		["Telegram", "https://t.me/share/url?url=%2$s&text=%1$s"],
		["Reddit", "https://www.reddit.com/submit?url=%2$s&title=%1$s"],
		["E-Mail", "mailto:?subject=CQ%%20Quest&body=%s%%20%s"],
	]
	var x := 236.0
	var y := 386.0
	for i in nets.size():
		var n: Array = nets[i]
		var b := _button(n[0], Vector2(x, y), Vector2(192, 44), _share_to.bind(n[1]))
		x += 202.0
		if i % 4 == 3:
			x = 236.0
			y += 54.0
	var row_y := 506.0
	_button(I18n.t("share.save"), Vector2(236, row_y), Vector2(240, 44), _save_screenshot)
	_button(I18n.t("share.copy"), Vector2(486, row_y), Vector2(200, 44), _copy_text)
	if OS.has_feature("web"):
		_button(I18n.t("share.native"), Vector2(696, row_y), Vector2(344, 44), _share_native, "PrimaryButton")
	_label(I18n.t("share.note"), Vector2(236, 564), 14, Palette.MUTED, Style.font_body)
	_button(I18n.t("common.close"), Vector2(924, 596), Vector2(132, 44), close, "PrimaryButton")


func _label(t: String, pos: Vector2, size: int, col: Color, font: Font) -> Label:
	var l := Style.label(t, size, col, font)
	l.position = pos
	if size <= 16:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 808
		l.size = Vector2(808, 0)
	_root.add_child(l)
	return l


func _button(t: String, pos: Vector2, sz: Vector2, cb: Callable, variation: String = "") -> Button:
	var b := Button.new()
	b.text = t
	b.position = pos
	b.custom_minimum_size = sz
	b.size = sz
	b.focus_mode = Control.FOCUS_NONE
	if variation != "":
		b.theme_type_variation = variation
	b.pressed.connect(func() -> void:
		Sfx.click()
		cb.call())
	_root.add_child(b)
	return b


# ---- actions ----------------------------------------------------------------------------

func _save_screenshot() -> bool:
	if _image == null:
		_toast(I18n.t("share.failed"))
		return false
	DirAccess.make_dir_recursive_absolute("user://shares")
	var path := "user://shares/cq-quest-%d.png" % int(Time.get_unix_time_from_system())
	if _image.save_png(path) != OK:
		_toast(I18n.t("share.failed"))
		return false
	_saved_path = path
	if not OS.has_feature("web"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path(path))
	_toast(I18n.t("share.saved"))
	return true


func _copy_text() -> void:
	DisplayServer.clipboard_set(_text_edit.text + " " + URL)
	_toast(I18n.t("share.copied"))


func _share_to(pattern: String) -> void:
	if _saved_path == "" and _image != null:
		_save_screenshot()
	var msg := _text_edit.text.uri_encode()
	var url := URL.uri_encode()
	var link := pattern
	# patterns use either sequential %s or positional %1$s / %2$s
	if pattern.contains("%1$s") or pattern.contains("%2$s"):
		link = link.replace("%1$s", msg).replace("%2$s", url)
	else:
		link = link % [msg, url]
	OS.shell_open(link)


func _share_native() -> void:
	if _image == null:
		return
	var b64 := Marshalls.raw_to_base64(_image.save_png_to_buffer())
	var js := """
(async () => {
  const bin = atob(%s);
  const bytes = Uint8Array.from(bin, c => c.charCodeAt(0));
  const file = new File([bytes], 'cq-quest.png', {type: 'image/png'});
  const data = {text: %s, url: %s};
  try {
    if (navigator.canShare && navigator.canShare({files: [file]})) { data.files = [file]; }
    await navigator.share(data);
  } catch (e) {}
})();
""" % [JSON.stringify(b64), JSON.stringify(_text_edit.text), JSON.stringify(URL)]
	JavaScriptBridge.eval(js)


func _toast(t: String) -> void:
	var l := Style.display_label(t, 18, Palette.INK)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.box(Palette.AMBER, 20, Palette.CLEAR, 0, Vector2(20, 10)))
	p.add_child(l)
	_root.add_child(p)
	p.position = Vector2(640.0 - p.get_combined_minimum_size().x / 2.0, 620)
	get_tree().create_timer(2.6).timeout.connect(func() -> void:
		if is_instance_valid(p):
			p.queue_free())
