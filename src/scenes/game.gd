extends Node2D

@export var start_hour: int = 12
@export var start_minute: int = 0
@export var end_hour: int = 12
@export var end_minute: int = 0
@export var duration: float = 5.0

@export var time_label: Label

var current_time: float = 0.0
var settings_enabled = false
var logs_enabled = false

@export var time_between_anomalies: float = 16.0
@export var MENUANIM : AnimationPlayer

func _ready() -> void:
	set_process(true)
	update_label(0.0)
	$Timer.wait_time = time_between_anomalies
	EventBus.gameover.connect(_game_over)

func _process(delta: float) -> void:
	current_time += delta
	var t = current_time / duration
	if t > 1.0:
		t = 1.0
	update_label(t)

func update_label(t: float) -> void:
	var start_total = start_hour % 12 * 60 + start_minute
	var end_total = end_hour % 12 * 60 + end_minute
	var total_minutes = end_total - start_total
	if total_minutes < 0:
		total_minutes += 12 * 60
	
	var current_total = start_total + total_minutes * t
	current_total = int(current_total) % (12 * 60)
	
	var hour = int(current_total / 60)
	var minute = int(current_total % 60)
	if hour == 0:
		hour = 12

	var am_pm_hour = (start_hour + int(total_minutes * t / 60)) % 24
	var period = "AM"
	if am_pm_hour >= 12:
		period = "PM"

	time_label.text = str(hour) + ":" + str(minute).pad_zeros(2) + " " + period

func form_anomaly() -> void:
	if is_free_minor_anom():
		var anoms = get_tree().get_nodes_in_group("anom_handler")
		var sel = anoms.pick_random()
		if sel.has_method("is_active"):
			if sel.is_active():
				print_debug("Anomaly already active, trying again")
				form_anomaly()
				return
		if sel.has_method("activate_anomaly"):
			sel.activate_anomaly()
			print("Anomaly created: ", sel.name)
	else:
		push_warning("All anomalies busy, cannot continue")

func form_major_anomaly() -> void:
	if is_free_major_anom():
		pass

func is_free_major_anom() -> bool:
	var anoms = get_tree().get_nodes_in_group("anom_major")
	var available = 0
	for i in anoms:
		if i.has_method("is_active"):
			if i.is_active():
				continue
			else:
				available += 1

	if available > 0:
		return true
	else:
		return false

func is_free_minor_anom() -> bool:
	var anoms = get_tree().get_nodes_in_group("anom_handler")
	var available = 0
	for i in anoms:
		if i.has_method("is_active"):
			if i.is_active():
				continue
			else:
				available += 1

	if available > 0:
		return true
	else:
		return false

func _on_timer_timeout() -> void:
	form_anomaly()

func _game_over() -> void:
	pass


func _on_x_pressed() -> void:
	EventBus.fade_screen.emit()
	EventBus.load_menu.emit()
	pass # Replace with function body.



func _on_settings_pressed() -> void:
	if logs_enabled:
		print("logs enabled already, hiding")
		_on_logs_return_pressed()
	if !settings_enabled :
		if MENUANIM.is_playing():
			await MENUANIM.animation_finished
		print("bringing up settings menu")
		MENUANIM.play("SettingEnable")
		await MENUANIM.animation_finished
		settings_enabled = true
		EventBus.disallow_zoom.emit()
	else :
		_on_settings_return_pressed()
	pass # Replace with function body.


func _on_settings_return_pressed() -> void:
	print("hiding settings menu")
	MENUANIM.play_backwards("SettingEnable")
	await MENUANIM.animation_finished
	settings_enabled = false
	EventBus.allow_zoom.emit()
	pass # Replace with function body.


func _on_logs_pressed() -> void:
	if settings_enabled:
		print("settings enabled already, hiding")
		_on_settings_return_pressed()
	if !logs_enabled :
		if MENUANIM.is_playing():
			await MENUANIM.animation_finished
		MENUANIM.play("logsEnable")
		await MENUANIM.animation_finished
		logs_enabled = true
		EventBus.disallow_zoom.emit()
	else :
		_on_logs_return_pressed()
		
	pass # Replace with function body.


func _on_logs_return_pressed() -> void:
	MENUANIM.play_backwards("logsEnable")
	await MENUANIM.animation_finished
	logs_enabled = false
	EventBus.allow_zoom.emit()
	pass # Replace with function body.
