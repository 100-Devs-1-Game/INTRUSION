extends Node

@warning_ignore("unused_signal")
signal light_changed(room: int, state: bool)
@warning_ignore("unused_signal")
signal out_of_energy
@warning_ignore("unused_signal")
signal energy_spent(amount: float)
@warning_ignore("unused_signal")
signal max_threat_level
@warning_ignore("unused_signal")
signal threat_level_increased(amount: float)
@warning_ignore("unused_signal")
signal anomaly_fixed
@warning_ignore("unused_signal")
signal gameover
@warning_ignore("unused_signal")
signal display_text(text: String)
@warning_ignore("unused_signal")
signal update_log_info(title: String, desc: String, date: String)
