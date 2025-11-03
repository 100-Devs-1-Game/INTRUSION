extends Node2D

@export var start_hour: int = 12
@export var start_minute: int = 0
@export var end_hour: int = 12
@export var end_minute: int = 0
@export var duration: float = 5.0

@export var time_label: Label

var current_time: float = 0.0

func _ready() -> void:
	set_process(true)
	update_label(0.0)

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

	# Determine AM/PM
	var am_pm_hour = (start_hour + int(total_minutes * t / 60)) % 24
	var period = "AM"
	if am_pm_hour >= 12:
		period = "PM"

	time_label.text = str(hour) + ":" + str(minute).pad_zeros(2) + " " + period
