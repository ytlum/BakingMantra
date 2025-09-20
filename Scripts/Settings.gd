extends Control

@onready var bgm_slider: HSlider = $BGM_Slider
@onready var sfx_slider: HSlider = $SFX_Slider
@onready var save_button: Button = $SaveButton
@onready var sound_label: Label = $SoundLabel
@onready var bgm_label: Label = $BGMLabel
@onready var setting_button: TextureButton = $SettingButton
@onready var panel_bg: Control = $PanelBG 

func _ready():
	# 默认隐藏
	panel_bg.visible = false
	bgm_slider.visible = false
	sfx_slider.visible = false
	bgm_label.visible = false
	sound_label.visible = false
	save_button.visible = false
	
	# 初始化滑块
	bgm_slider.value = db_to_linear(MusicManager.bgm_volume_db)
	sfx_slider.value = db_to_linear(MusicManager.sfx_volume_db)

	# 连接滑块变化信号
	bgm_slider.connect("value_changed", Callable(self, "_on_bgm_changed"))
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_changed"))

	# 连接按钮信号
	setting_button.pressed.connect(_on_setting_pressed)
	save_button.pressed.connect(_on_save_pressed)

# ------------------ 显示设置面板 ------------------
func _on_setting_pressed():
	panel_bg.visible = true
	bgm_slider.visible = true
	sfx_slider.visible = true
	bgm_label.visible = true
	sound_label.visible = true
	save_button.visible = true

	# 同步最新音量
	bgm_slider.value = db_to_linear(MusicManager.bgm_volume_db)
	sfx_slider.value = db_to_linear(MusicManager.sfx_volume_db)

# ------------------ 保存音量 ------------------
func _on_save_pressed():
	MusicManager.set_bgm_volume(bgm_slider.value)
	MusicManager.set_sfx_volume(sfx_slider.value)

	# 隐藏设置面板
	panel_bg.visible = false
	bgm_slider.visible = false
	sfx_slider.visible = false
	bgm_label.visible = false
	sound_label.visible = false
	save_button.visible = false

# ------------------ 滑块变化 ------------------
func _on_bgm_changed(value: float):
	MusicManager.set_bgm_volume(value)

func _on_sfx_changed(value: float):
	MusicManager.set_sfx_volume(value)
