extends Node

@onready var player = $AudioStreamPlayer2D

func _ready():
	player.stream = preload("res://Assets/Walen - Gameboy (freetouse.com).mp3")
	player.play()

func get_volume() -> float:
	return db_to_linear(player.volume_db)

func set_volume(volume: float) -> void:
	if volume <= 0.01:
		player.volume_db = -80.0
	else:
		player.volume_db = linear_to_db(volume)

func change_track(path: String) -> void:
	if player.stream and player.stream.resource_path == path:
		return
	if path.begins_with("res://"):
		player.stream = load(path)
	else:
		if path.ends_with(".mp3"):
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var stream = AudioStreamMP3.new()
				stream.data = file.get_buffer(file.get_length())
				player.stream = stream
		elif path.ends_with(".ogg"):
			var stream = AudioStreamOggVorbis.load_from_file(path)
			player.stream = stream
	player.play()
