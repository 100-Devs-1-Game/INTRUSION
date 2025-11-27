extends Button

@export var log_title: String = "[LOG TITLE]"
@export_multiline var log_desc:  = "[LOG DESC]"
@export var log_date: String = "January 1st, 1970"

@export var log_locked: bool = false

@export var default_y: float = 50.189
@export var hover_y: float = 60.0

var current_y_size: float
var target_y_size: float

func _ready() -> void:
	current_y_size = custom_minimum_size.y
	target_y_size = current_y_size
	if !log_locked:
		text = "  " + log_title
	else:
		text = "  " + "[REDACTED]"

func _process(delta: float) -> void:
	current_y_size = lerpf(current_y_size, target_y_size, 0.3)
	custom_minimum_size.y = current_y_size

func _on_mouse_entered() -> void:
	target_y_size = hover_y
	$AnimationPlayer.play("hover")

func _on_mouse_exited() -> void:
	target_y_size = default_y
	$AnimationPlayer.play_backwards("hover")

func _on_pressed() -> void:
	if !log_locked:
		EventBus.update_log_info.emit(log_title, log_desc, log_date)
	else:
		var redacted = ""
		for char in log_desc:
			if char == " ":
				redacted += " "
			else:
				redacted += "X"
		EventBus.update_log_info.emit("[REDACTED]", redacted, log_date)
