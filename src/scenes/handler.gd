extends Node2D

@export var rooms: Array[Node2D]
@export var zoom_in_amount: Vector2 = Vector2(0.1, 0.1)
@export var zoom_out_amount: Vector2 = Vector2(0.1, 0.1)

@export var min_zoom: Vector2 = Vector2(0.3, 0.3)
@export var max_zoom: Vector2 = Vector2(2.0, 2.0)
@export var zoom_interp_speed: float = 6.0

@export var camera: Camera2D
@export var light_button: BaseButton
@export var next_button: BaseButton
@export var prev_button: BaseButton
@export var stat_overlay: ColorRect

@export var animator: AnimatedSprite2D

var left_limit: bool = false
var right_limit: bool = false
var top_limit: bool = false
var bottom_limit: bool = false

var current_camera: int = 0
var camera_zoom: Vector2 = Vector2(1.0, 1.0)
var camera_zoom_target: Vector2 = Vector2(1.0, 1.0)
var camera_move_speed: float = 132.0
var is_zooming: bool = false
var room_cap: int
var static_show_time: float = 0.3

@export var current_room: Node2D

var max_energy: float = 100.0
var current_energy: float = 100.0
var energy_regeneration: float = 0.28
var energy_drain: float = 0.6
var current_usage: int = 0

func _ready() -> void:
	light_button.pressed.connect(func(): current_room.toggle_light())
	next_button.pressed.connect(next_camera)
	prev_button.pressed.connect(prev_camera)
	EventBus.light_changed.connect(update_energy_use)
	room_cap = rooms.size() - 1
	if camera:
		camera_zoom = camera.zoom
		camera_zoom_target = camera_zoom
	update_energy_use()

func _process(delta: float) -> void:
	if not rooms or not rooms[current_camera]:
		return

	if Input.is_action_just_pressed("next"):
		current_camera = (current_camera + 1) % (room_cap + 1)
		change_room(current_camera)
	elif Input.is_action_just_pressed("previous"):
		current_camera = (current_camera - 1 + (room_cap + 1)) % (room_cap + 1)
		change_room(current_camera)
	elif Input.is_action_just_pressed("lights"):
		current_room.toggle_light()

	if Input.is_action_just_pressed("zoom in"):
		zoom_in()
	elif Input.is_action_just_pressed("zoom out"):
		zoom_out()

	if Input.is_action_pressed("up"):
		if !top_limit:
			camera.global_position.y -= camera_move_speed * camera.zoom.x * delta
	if Input.is_action_pressed("down"):
		if !bottom_limit:
			camera.global_position.y += camera_move_speed * camera.zoom.x * delta
	if Input.is_action_pressed("left"):
		if !left_limit:
			camera.global_position.x -= camera_move_speed * (camera.zoom.x + 0.50) * delta
	if Input.is_action_pressed("right"):
		if !right_limit:
			camera.global_position.x += camera_move_speed * camera.zoom.x * delta

	if camera:
		var t = clamp(zoom_interp_speed * delta, 0.0, 1.0)
		camera_zoom = camera_zoom.lerp(camera_zoom_target, t)
		camera.zoom = camera_zoom
		is_zooming = camera_zoom.distance_to(camera_zoom_target) > 0.001

	if current_energy < max_energy:
		current_energy += energy_regeneration * delta

	if current_usage > 0:
		current_energy -= energy_drain * current_usage * delta

	if current_energy <= 0.0:
		EventBus.out_of_energy.emit()

	update_ui()

	if $SideLimits/LEFT.is_on_screen():
		left_limit = true
	else:
		left_limit = false

	if $SideLimits/RIGHT.is_on_screen():
		right_limit = true
	else:
		right_limit = false

	if $SideLimits/TOP.is_on_screen():
		top_limit = true
	else:
		top_limit = false

	if $SideLimits/BOTTOM.is_on_screen():
		bottom_limit = true
	else:
		bottom_limit = false

func zoom_in() -> void:
	if not camera:
		return
	camera_zoom_target = camera_zoom_target + zoom_in_amount
	camera_zoom_target.x = clamp(camera_zoom_target.x, min_zoom.x, max_zoom.x)
	camera_zoom_target.y = clamp(camera_zoom_target.y, min_zoom.y, max_zoom.y)
	is_zooming = true

func zoom_out() -> void:
	if not camera:
		return
	camera_zoom_target = camera_zoom_target - zoom_out_amount
	camera_zoom_target.x = clamp(camera_zoom_target.x, min_zoom.x, max_zoom.x)
	camera_zoom_target.y = clamp(camera_zoom_target.y, min_zoom.y, max_zoom.y)
	is_zooming = true

func next_camera() -> void:
	current_camera = (current_camera + 1) % (room_cap + 1)
	change_room(current_camera)

func prev_camera() -> void:
	current_camera = (current_camera - 1 + (room_cap + 1)) % (room_cap + 1)
	change_room(current_camera)


func update_ui() -> void:
	$CanvasLayer/EnergyBar.max_value = max_energy
	$CanvasLayer/EnergyBar.value = current_energy

func center_camera_on_view() -> void:
	if not camera:
		return

	var vp_size = get_viewport().get_visible_rect().size
	camera.global_position.x = vp_size.x / 2
	camera.global_position.y = vp_size.y / 2


func change_room(num: int) -> void:
	pick_glitch()
	animator.visible = true
	var change_to = rooms[num]
	current_room = change_to
	$CanvasLayer/RoomNamelbl.text = current_room.name
	for r in rooms:
		r.visible = r == change_to
	await get_tree().create_timer(0.2).timeout
	animator.visible = false

func pick_glitch() -> void:
	var choices = ["glitch", "glitch_1", "glitch_2", "glitch_3", "glitch_4"]
	var state = [true, false]
	var choice = choices.pick_random()
	if animator:
		animator.flip_h = state.pick_random()
		animator.flip_v = state.pick_random()
		if animator.sprite_frames.has_animation(choice):
			animator.play("glitch_4")

func update_energy_use() -> void:
	current_usage = 0
	for i in rooms:
		if i.has_method("get_light_state"):
			if i.get_light_state():
				current_usage += 1

	print("Current usage is: ", str(current_usage))
