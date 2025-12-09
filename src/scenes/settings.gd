class_name settings extends Control

@export var MASTERAUDIO : HSlider
@export var SFXAUDIO : HSlider
@export var MUSICAUDIO : HSlider

func _ready() -> void:
	Global.master_audio_level = MASTERAUDIO.value/100
	Global.sound_effects_level = SFXAUDIO.value/100
	Global.music_level = MUSICAUDIO.value/100
	pass
	


func _on_master_value_changed(value: float) -> void:
	print("changing master audio level to: " + str(value))
	Global.master_audio_level = value/100
	pass # Replace with function body.


func _on_sfx_value_changed(value: float) -> void:
	print("changing sfx audio level to: " + str(value))
	Global.sound_effects_level = value/100
	pass # Replace with function body.


func _on_music_value_changed(value: float) -> void:
	print("changing music audio level to: " + str(value))
	Global.music_level = value/100
	pass # Replace with function body.
