class_name Scene_manager extends Node2D

#THIS SHOULD BE THE FIRST SCENE LOADED 

#@export var COLORSCREEN : Control
@export var SCENENODE : Node
@export var SCREENANIM : AnimationPlayer
@export var GAMEOVERANIM: AnimationPlayer
var main_game : Node2D
var main_menu : Control


func _ready() -> void:
	#main_menu = preload("res://scenes/game.tscn").instantiate()
	EventBus.load_game.connect(load_main_game)
	EventBus.load_menu.connect(load_main_menu)
	EventBus.fade_screen.connect(_increase_fade_opacity)
	EventBus.gameover.connect(_game_over)
	
	load_main_menu()

func load_main_menu() -> void:
	if SCREENANIM.is_playing() :
		await SCREENANIM.animation_finished
	GAMEOVERANIM.play(&"RESET")
	await GAMEOVERANIM.animation_finished
	_lower_fade_opacity()
	print("loading main menu")
	if main_game: 
		main_game.queue_free()
	main_menu = preload("res://scenes/title.tscn").instantiate()
	SCENENODE.add_child(main_menu)
	#self.move_child(COLORSCREEN,0)

func load_main_game() -> void:
	if SCREENANIM.is_playing() :
		await SCREENANIM.animation_finished
	_lower_fade_opacity()
	print("loading main game")
	if main_menu:
		main_menu.queue_free()
	main_game = preload("res://scenes/game.tscn").instantiate()
	SCENENODE.add_child(main_game)
	#self.move_child(COLORSCREEN,0)

func _lower_fade_opacity() -> void:
	SCREENANIM.play("FadeScreen")
	

func _increase_fade_opacity() -> void:
	SCREENANIM.play_backwards("FadeScreen")

func _game_over() -> void:
	GAMEOVERANIM.play("GameOverFade")
	await GAMEOVERANIM.animation_finished
	EventBus.fade_screen.emit()
	EventBus.load_menu.emit()
