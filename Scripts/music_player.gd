##extends AudioStreamPlayer2D
extends Node
#
#@onready var music: AudioStreamPlayer = $AudioStreamPlayer
#
#func _ready():
	## Make sure music is playing only once
	#if not music.playing:
		#music.play()
		#
#
#func play_music(track: AudioStream):
	## Switch to a new track if needed
	#if music.stream != track:
		#music.stream = track
		#music.play()
#
#func stop_music():
	#music.stop()
