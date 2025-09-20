extends Node

var music_player: AudioStreamPlayer
var bgm_volume_db: float = 0.0
var sfx_volume_db: float = 0.0

func _ready():
	# 创建音乐播放器
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	# 加载 MP3 音乐
	music_player.stream = load("res://assets/audio/bgmmusic.mp3")
	music_player.autoplay = true

	# 连接播放结束信号，实现循环
	music_player.finished.connect(func():
		music_player.play()
	)

	load_settings()
	music_player.volume_db = bgm_volume_db
	music_player.play()

# ------------------ BGM ------------------
func set_bgm_volume(value: float):
	bgm_volume_db = linear_to_db(value)
	music_player.volume_db = bgm_volume_db
	save_settings()

# ------------------ SFX ------------------
func set_sfx_volume(value: float):
	sfx_volume_db = linear_to_db(value)
	save_settings()

# 播放 SFX
func play_sfx(stream: AudioStream):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = stream
	sfx.volume_db = sfx_volume_db
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

# ------------------ 保存 & 读取 ------------------
func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "bgm_volume", bgm_volume_db)
	config.set_value("audio", "sfx_volume", sfx_volume_db)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		bgm_volume_db = config.get_value("audio", "bgm_volume", linear_to_db(0.5))
		sfx_volume_db = config.get_value("audio", "sfx_volume", linear_to_db(0.5))
	else:
		bgm_volume_db = linear_to_db(0.5)
		sfx_volume_db = linear_to_db(0.5)
		save_settings()
	music_player.volume_db = bgm_volume_db
