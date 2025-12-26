extends Node

const SAVE_FILE= "user://settings.cfg"

var master_audio_level: int:
	set(i):
		master_audio_level= i
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), i / 100.0)

var sound_effects_level: int:
	set(i):
		sound_effects_level= i
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sfx"), i / 100.0)

var music_level: int:
	set(i):
		music_level= i
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), i / 100.0)

var fullscreen: bool:
	set(b):
		fullscreen= b
		if OS.get_name() == "Web":
			return
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if b else\
			DisplayServer.WINDOW_MODE_WINDOWED)



func _ready() -> void:
	master_audio_level= 50
	sound_effects_level= 50
	music_level= 50
	fullscreen= false

	load_settings()


func save_settings():
	var config = ConfigFile.new()

	config.set_value("Audio", "master_volume", master_audio_level)
	config.set_value("Audio", "sfx_volume", sound_effects_level)
	config.set_value("Audio", "music_volume", music_level)
	config.set_value("Misc", "fullscreen", fullscreen)

	config.save(SAVE_FILE)


func load_settings():
	var config = ConfigFile.new()
	if config.load(SAVE_FILE) != OK:
		return

	master_audio_level= config.get_value("Audio", "master_volume", 0.7)
	music_level= config.get_value("Audio", "music_volume", 0.7)
	sound_effects_level= config.get_value("Audio", "sfx_volume", 0.7)
	fullscreen= config.get_value("Misc", "fullscreen")
