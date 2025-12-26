class_name settings extends Control

@export var MASTERAUDIO : HSlider
@export var SFXAUDIO : HSlider
@export var MUSICAUDIO : HSlider
@export var INGAME : bool



func _ready() -> void:
	setLocals()


func setGlobals() -> void:
	Global.master_audio_level = MASTERAUDIO.value
	Global.sound_effects_level = SFXAUDIO.value
	Global.music_level = MUSICAUDIO.value


func setLocals() -> void:
	MASTERAUDIO.value = Global.master_audio_level
	SFXAUDIO.value = Global.sound_effects_level
	MUSICAUDIO.value = Global.music_level


func _on_master_value_changed(value: float) -> void:
	print("changing master audio level to: " + str(value))
	Global.master_audio_level = value


func _on_sfx_value_changed(value: float) -> void:
	print("changing sfx audio level to: " + str(value))
	Global.sound_effects_level = value


func _on_music_value_changed(value: float) -> void:
	print("changing music audio level to: " + str(value))
	Global.music_level = value
