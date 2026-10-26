extends Control

@onready var hp_label = $Stats/HPLabel
@onready var atk_label = $Stats/AtkLabel
@onready var def_label = $Stats/DefLabel
@onready var spd_label = $Stats/SpdLabel
@onready var fatigue_label = $Stats/FatigueLabel
@onready var train_atk = $TrainMenu/TrainAtkBtn
@onready var train_def = $TrainMenu/TrainDefBtn
@onready var train_spd = $TrainMenu/TrainSpdBtn
@onready var result_label = $ResultLabel
@onready var back_btn = $BackBtn

func _ready():
	train_atk.pressed.connect(func(): train_stat("attack"))
	train_def.pressed.connect(func(): train_stat("defense"))
	train_spd.pressed.connect(func(): train_stat("speed"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))
	update_ui()

func update_ui():
	if GameManager.current_pet.is_empty():
		return
	var stats = GameManager.current_pet.stats
	hp_label.text = "HP: " + str(stats.hp)
	atk_label.text = "Attack: " + str(stats.attack)
	def_label.text = "Defense: " + str(stats.defense)
	spd_label.text = "Speed: " + str(stats.speed)
	fatigue_label.text = "Fatigue: " + str(GameManager.current_pet.fatigue)

func train_stat(stat: String):
	var res = GameManager.train(stat)
	if res.success:
		result_label.text = "+" + str(res.gain) + " to " + res.stat + "!"
	else:
		result_label.text = res.message
	update_ui()
