extends Control

@onready var music_slider = $Panel/VBoxContainer/MusicSlider
@onready var sfx_slider = $Panel/VBoxContainer/SFXSlider
@onready var track_select = $Panel/VBoxContainer/TrackSelect
@onready var import_btn = $Panel/VBoxContainer/ImportTrackBtn
@onready var close_btn = $Panel/VBoxContainer/CloseBtn

var tracks = {
	"Gameboy": "res://Assets/Walen - Gameboy (freetouse.com).mp3",
	"Harlem Heat": "res://Assets/Dagored - Harlem Heat (freetouse.com).mp3"
}

func _ready():
	close_btn.pressed.connect(queue_free)
	import_btn.pressed.connect(_on_import_pressed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	track_select.item_selected.connect(_on_track_selected)
	
	# Populate tracks
	track_select.clear()
	for t_name in tracks.keys():
		track_select.add_item(t_name)
		
	if MusicManager.has_method("get_volume"):
		music_slider.value = MusicManager.get_volume()
	if SFXManager.has_method("get_volume"):
		sfx_slider.value = SFXManager.get_volume()

func _on_music_changed(val: float):
	if MusicManager.has_method("set_volume"):
		MusicManager.set_volume(val)

func _on_sfx_changed(val: float):
	if SFXManager.has_method("set_volume"):
		SFXManager.set_volume(val)

func _on_track_selected(index: int):
	var t_name = track_select.get_item_text(index)
	var path = tracks.get(t_name, "")
	if path != "" and MusicManager.has_method("change_track"):
		MusicManager.change_track(path)

func _on_import_pressed():
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.filters = PackedStringArray(["*.mp3, *.ogg ; Audio Files"])
	dialog.title = "Select Custom Music"
	dialog.file_selected.connect(_on_custom_file_selected)
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)

func _on_custom_file_selected(path: String):
	var filename = path.get_file().get_basename()
	tracks[filename] = path
	track_select.add_item(filename)
	track_select.select(track_select.item_count - 1)
	_on_track_selected(track_select.item_count - 1)
