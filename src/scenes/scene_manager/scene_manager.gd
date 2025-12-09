class_name scene_manager extends Node2D

#THIS SHOULD BE THE FIRST SCENE LOADED 

var main_game : Node2D
var main_menu : Control


func _ready() -> void:
	#main_menu = preload("res://scenes/game.tscn").instantiate()
	EventBus.load_game.connect(load_main_game)
	EventBus.load_menu.connect(load_main_menu)
	
	load_main_menu()

func load_main_menu() -> void:
	print("loading main menu")
	if main_game: 
		main_game.queue_free()
	main_menu = preload("res://scenes/title.tscn").instantiate()
	self.add_child(main_menu)

func load_main_game() -> void:
	print("loading main game")
	if main_menu:
		main_menu.queue_free()
	main_game = preload("res://scenes/game.tscn").instantiate()
	self.add_child(main_game)
