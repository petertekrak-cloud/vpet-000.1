extends Control

@onready var coins_label = $CoinsLabel
@onready var silver_btn = $UpgradesList/Silver
@onready var gold_btn = $UpgradesList/Gold
@onready var crimson_btn = $UpgradesList/Crimson
@onready var back_btn = $BackBtn

func _ready():
	silver_btn.pressed.connect(func(): buy_upgrade("silver"))
	gold_btn.pressed.connect(func(): buy_upgrade("gold"))
	crimson_btn.pressed.connect(func(): buy_upgrade("crimson"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))
	update_ui()

func update_ui():
	coins_label.text = "Coins: " + str(GameManager.coins) + " | Current Tier: " + str(GameManager.digivice_tier)
	if GameManager.digivice_tier >= 2:
		silver_btn.disabled = true
		silver_btn.text = "Silver - UNLOCKED"
	if GameManager.digivice_tier >= 3:
		gold_btn.disabled = true
		gold_btn.text = "Gold - UNLOCKED"
	if GameManager.digivice_tier >= 4:
		crimson_btn.disabled = true
		crimson_btn.text = "Crimson - UNLOCKED"

func buy_upgrade(upgrade_id: String):
	if GameManager.upgrade_digivice(upgrade_id):
		update_ui()
