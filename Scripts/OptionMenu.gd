extends Control  # The root node is a Control node
##
##var audio_slider
##var sound_slider
##var audio_player
##var sound_player
##var last_audio_slider_value = -1
##var last_sound_slider_value = -1
##
### Called when the scene is ready
##func _ready():
	### Get references to the sliders
	##audio_slider = $AudioSlider
	##sound_slider = $SoundSlider
	##
	### Ensure sliders exist and are of type Slider
	##if not audio_slider or not sound_slider:
		##print("Error: One or both sliders are missing!")
		##return
	##
	##if not audio_slider is Slider or not sound_slider is Slider:
		##print("Error: The nodes are not sliders!")
		##return
	##
	### Get references to the AudioStreamPlayer nodes
	##audio_player = $AudioPlayer
	##sound_player = $SoundPlayer
	##
	##if not audio_player or not sound_player:
		##print("Error: One of the audio players is missing!")
		##return
	##
	### Load MP3 audio file
	##var audio_file = load("res://assets/audio/bgm.mp3") 
	##if audio_file:
		##print("Audio file loaded successfully!")
	##else:
		##print("Failed to load audio file!")
		##
	##var sound_file = load("res://assets/audio/bgm.mp3") 
	##if sound_file:
		##print("Sound file loaded successfully!")
	##else:
		##print("Failed to load sound file!")
	##
	##audio_player.stream = audio_file  # Assign the audio file to the audio player
	##sound_player.stream = sound_file 
	##
	### Start playing the audio
	##audio_player.play()  
	##print("Audio is now playing.")
	##
	##sound_player.play()
	##
	### Load saved settings (if any)
	##var settings = load_settings()
	##
	### Set slider values based on saved settings
	##audio_slider.value = settings.audio_volume
	##sound_slider.value = settings.sound_volume
	##
	### Apply the initial volumes (in decibels)
	##audio_player.volume_db = linear_to_db(settings.audio_volume / 100.0)  
	##sound_player.volume_db = linear_to_db(settings.sound_volume / 100.0) 
##
### Load settings from a file or use default values
##func load_settings():
	##var settings = {"audio_volume": 50, "sound_volume": 50}  # Default values
	##return settings
##
##
### Called every frame (every process tick)
##func _process(delta):
	### Check if audio slider value has changed
	##if audio_slider.value != last_audio_slider_value:
		##last_audio_slider_value = audio_slider.value
		### Update background music volume
		##audio_player.volume_db = linear_to_db(audio_slider.value / 100.0)
##
	### Check if sound slider value has changed
	##if sound_slider.value != last_sound_slider_value:
		##last_sound_slider_value = sound_slider.value
		### Update sound effects volume
		##sound_player.volume_db = linear_to_db(sound_slider.value / 100.0)
		#
#extends Control  # The root node is a Control node
#
#@onready var audio_slider = $AudioSlider
#@onready var sound_slider = $SoundSlider
#@onready var audio_player = $AudioPlayer
#@onready var sound_player = $SoundPlayer
#@onready var save_button = $SaveButton
#
#var last_audio_slider_value = -1
#var last_sound_slider_value = -1
#
#func _ready():
	## Check if all required nodes exist
	#if not audio_slider or not sound_slider:
		#print("Error: One or both sliders are missing!")
		#return
#
	#if not audio_slider is Slider or not sound_slider is Slider:
		#print("Error: The nodes are not sliders!")
		#return
#
	#if not audio_player or not sound_player:
		#print("Error: One of the audio players is missing!")
		#return
#
	## Load audio files
	#var audio_file = load("res://assets/audio/bgm.mp3") 
	#if audio_file:
		#audio_player.stream = audio_file
	#else:
		#print("Failed to load audio file!")
#
	#var sound_file = load("res://assets/audio/bgm.mp3") 
	#if sound_file:
		#sound_player.stream = sound_file
	#else:
		#print("Failed to load sound file!")
#
	## Play audio
	#audio_player.play()
	#sound_player.play()
#
	## Load saved settings
	#GlobalSetting.load_settings()
#
	#audio_slider.value = GlobalSetting.volume  * 100
	#sound_slider.value = GlobalSetting.volume  * 100
#
	## Apply initial volumes
	#audio_player.volume_db = linear_to_db(GlobalSetting.volume)
	#sound_player.volume_db = linear_to_db(GlobalSetting.volume)
#
	## Connect Save button
	#save_button.pressed.connect(_on_save_pressed)
#
#func _on_save_pressed():
	#var new_audio_volume = audio_slider.value / 100.0
	#var new_sound_volume = sound_slider.value / 100.0
#
	#GlobalSetting.volume = new_audio_volume  # Save one value or make two vars if needed
	#GlobalSetting.save_settings()
#
	## Apply new volumes immediately
	#audio_player.volume_db = linear_to_db(new_audio_volume)
	#sound_player.volume_db = linear_to_db(new_sound_volume)
#
	## Also apply to main scene if needed
	#var music_player = get_tree().root.get_node("Main/MusicPlayer")
	#if music_player:
		#music_player.volume_db = linear_to_db(new_audio_volume)
#
#func _process(delta):
	## Update volume in real time if changed
	#if audio_slider.value != last_audio_slider_value:
		#last_audio_slider_value = audio_slider.value
		#audio_player.volume_db = linear_to_db(audio_slider.value / 100.0)
#
	#if sound_slider.value != last_sound_slider_value:
		#last_sound_slider_value = sound_slider.value
		#sound_player.volume_db = linear_to_db(sound_slider.value / 100.0)
