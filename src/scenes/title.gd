extends Control

@export var play_button: BaseButton
@export var logs_button: BaseButton
@export var settings_button: BaseButton
@export var credits_button: BaseButton
@export var quit_button: BaseButton

#conf quit buttons
@export var confirm_quit: BaseButton
@export var cancel_quit: BaseButton

#exit cred
@export var exit_creds: BaseButton

#exit logs
@export var exit_logs: BaseButton



func _ready() -> void:
	_connect_buttons()


func _connect_buttons() -> void:
	if play_button:
		play_button.pressed.connect(play_game)
	if logs_button:
		logs_button.pressed.connect(load_logs)
	if settings_button:
		settings_button.pressed.connect(load_settings)
	if credits_button:
		credits_button.pressed.connect(load_credits)
	if quit_button:
		quit_button.pressed.connect(func(): $CanvasLayer/UI.play("quit_req"); change_menu())

	if confirm_quit:
		confirm_quit.pressed.connect(func(): get_tree().quit())
	if cancel_quit:
		cancel_quit.pressed.connect(func(): $CanvasLayer/UI.play_backwards("quit_req"); change_menu())

	if exit_creds:
		exit_creds.pressed.connect(func(): $CanvasLayer/UI.play_backwards("credits"); change_menu())

	if exit_logs:
		exit_logs.pressed.connect(func(): $CanvasLayer/UI.play_backwards("logs"); change_menu())


func change_menu() -> void:
	$CanvasLayer/UICont/Glitch.visible = true
	$CanvasLayer/Fade/Glitch.visible = true
	await $CanvasLayer/UI.animation_finished
	$CanvasLayer/UICont/Glitch.visible = false
	$CanvasLayer/Fade/Glitch.visible = false


func play_game() -> void:
	change_menu()
	$CanvasLayer/UICont.visible = false
	$CanvasLayer/UI.play("load")
	await $CanvasLayer/UI.animation_finished
	$CanvasLayer/UI.play("loadloop")
	plh_load_bar()
	await $CanvasLayer/Secondary.animation_finished
	#get_tree().change_scene_to_file("res://scenes/game_deprecated.tscn")
	EventBus.load_game.emit()


func load_logs() -> void:	
	change_menu()
	$CanvasLayer/UI.play("logs")


func load_settings() -> void:
	change_menu()
	$CanvasLayer/UI.play("settings")


func load_credits() -> void:
	change_menu()
	$CanvasLayer/UI.play("credits")


func plh_load_bar() -> void:
	var anim: AnimationPlayer = $CanvasLayer/Secondary
	anim.play("load")
	while anim.current_animation_position < anim.current_animation_length:
		await get_tree().create_timer(randf_range(0.05, 0.5)).timeout

		anim.speed_scale = 0.0

		await get_tree().create_timer(randf_range(0.2, 0.5)).timeout

		anim.speed_scale = 0.6


func _on_exit_settings():
	$CanvasLayer/UI.play_backwards("settings")
	change_menu()
	
