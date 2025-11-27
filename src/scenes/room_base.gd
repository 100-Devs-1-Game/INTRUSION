extends Node2D

@export var room_id: int = 1
@export var light_ver: Sprite2D
@export var light_on: bool = false
@export var disable_light: bool = false

func _ready() -> void:
	EventBus.out_of_energy.connect(toggle_light.bind(false))
	toggle_light(light_on)

func toggle_light(state = null) -> void:
	if !disable_light:
		if state == null:
			light_on = !light_on
		else:
			light_on = state

		light_ver.visible = light_on
		EventBus.light_changed.emit(room_id, light_on)

func get_light_state() -> bool:
	return light_on
