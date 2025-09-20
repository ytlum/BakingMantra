# GlobalSettings.gd
extends Node

var volume: float = 0.5  # Default volume

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.save("res://Scripts/settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		volume = config.get_value("audio", "volume", volume)
