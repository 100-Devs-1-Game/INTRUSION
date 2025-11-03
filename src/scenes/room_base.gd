extends Node2D

@export var light_ver: Sprite2D
@export var light_on: bool = true
@export var disable_light: bool = false

@export var room_anomalies: Array[Texture2D]


func _ready() -> void:
	EventBus.out_of_energy.connect(toggle_light.bind(false))

func toggle_light(state = null) -> void:
	if !disable_light:
		if state == null:
			light_on = !light_on
		else:
			light_on = state

		light_ver.visible = light_on
		EventBus.light_changed.emit()

func get_light_state() -> bool:
	return light_on
