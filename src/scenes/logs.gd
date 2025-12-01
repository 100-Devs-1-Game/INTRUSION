extends Control

@onready var time_label: Label = $Time

@onready var log_title: Label = $LogTitle
@onready var log_info: TextEdit = $LogInfo
@onready var log_date: Label = $Datelbl

func _ready() -> void:
	EventBus.update_log_info.connect(update_log)
	

func update_log(title: String, desc: String, date: String) -> void:
	log_title.text = title
	log_info.text = desc
	log_date.text = date

	if title == "INTRUSION":
		log_info.visible = false
		$IntLog.visible = true
	else:
		$IntLog.visible = false
		log_info.visible = true

func _process(delta: float) -> void:
	var t = Time.get_time_dict_from_system(false)
	var hour_24 = t["hour"]
	var am_pm = "AM"
	var hour_12 = hour_24

	if hour_24 == 0:
		hour_12 = 12
	elif hour_24 >= 12:
		am_pm = "PM"
		if hour_24 > 12:
			hour_12 = hour_24 - 12

	var hour_str = str(hour_12).pad_zeros(2)
	var minute_str = str(t["minute"]).pad_zeros(2)

	time_label.text = "%s:%s %s" % [hour_str, minute_str, am_pm]
