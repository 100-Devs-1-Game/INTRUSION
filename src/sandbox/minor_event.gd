extends Area2D

@export var anomaly_room_id: int = 1
@export var anomaly_severity: float = 1.5
@export var anomaly_time_pause: float = 12.0
@export var anomaly_animation_name: String = "default"
@export var replay_animation: bool = false

@export var anim: AnimatedSprite2D
@export var sheet: SpriteFrames
@export var dark_transition_initial: Texture2D
@export var dark_transition_final: Texture2D

var anomaly_active: bool = false
var is_lit: bool = true

@onready var dark = $Dark

func _ready() -> void:
	anim.sprite_frames = sheet
	EventBus.light_changed.connect(update_visual)
	if dark:
		dark.scale = anim.scale

func update_visual(room: int, state: bool) -> void:
	if room == anomaly_room_id:
		if dark_transition_initial:
			if anomaly_active:
				if dark_transition_final != null:
					dark.texture = dark_transition_final
				else:
					dark.texture = null
			else:
				dark.texture = dark_transition_initial
		dark.visible = !state
		anim.visible = state
		is_lit = state

func activate_anomaly() -> void:
	if sheet:
		if not sheet.has_animation(anomaly_animation_name):
			print("Animation not found: ", anomaly_animation_name)
			return

		if replay_animation:
			anim.sprite_frames.set_animation_loop(anomaly_animation_name, true)
		anim.speed_scale = 1.0
		anim.play(anomaly_animation_name)
	anomaly_active = true
	update_visual(anomaly_room_id, is_lit)

	while anomaly_active:
		EventBus.threat_level_increased.emit(anomaly_severity)
		await get_tree().create_timer(anomaly_time_pause).timeout


func fix_anomaly() -> void:
	anomaly_active = false
	EventBus.energy_spent.emit(1.5)
	if sheet:
		anim.play_backwards(anomaly_animation_name)
		if replay_animation:
			anim.speed_scale = 3.0
			anim.sprite_frames.set_animation_loop(anomaly_animation_name, false)
	update_visual(anomaly_room_id, is_lit)


func is_active() -> bool:
	return anomaly_active


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == 0:
			if is_active():
				print("Anomaly fixed")
				EventBus.anomaly_fixed.emit()
				fix_anomaly()


func _on_mouse_shape_entered(shape_idx: int) -> void:
	EventBus.display_text.emit("Object: " + name)


func _on_mouse_shape_exited(shape_idx: int) -> void:
	EventBus.display_text.emit("")
