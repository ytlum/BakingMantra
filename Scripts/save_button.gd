extends Button

# Declare variables for sliders
var audio_slider
var sound_slider
var File

# This function will be called when the Save button is pressed
func _on_Save_button_pressed():
	
	audio_slider = get_node("/root/OptionMenu/AudioSlider") 
	sound_slider = get_node("/root/OptionMenu/SoundSlider") 

	# Save the settings first
	save_settings()

	# Immediately change to the main scene
	get_tree().change_scene("res://main.tscn")

# Function to save settings 
func save_settings():
	var file = File.new()
	if file.open("res://Setting.cfg", File.WRITE) == OK:
		# Save audio and sound slider values to the file
		file.store_line("audio_volume=" + str(audio_slider.value))
		file.store_line("sound_volume=" + str(sound_slider.value))
		file.close()
