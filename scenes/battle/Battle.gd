extends Control

@onready var player_name = $PlayerSide/PlayerName
@onready var player_hp = $PlayerSide/PlayerHPBar
@onready var enemy_name = $EnemySide/EnemyName
@onready var enemy_hp = $EnemySide/EnemyHPBar
@onready var battle_log = $BattleLog
@onready var attack_btn = $ActionMenu/AttackBtn
@onready var special_btn = $ActionMenu/SpecialBtn
@onready var run_btn = $ActionMenu/RunBtn
@onready var back_btn = $BackBtn

var enemy = {}
var player_hp_current = 100
var enemy_hp_current = 100
var turn = "player"

func _ready():
	attack_btn.pressed.connect(_on_attack)
	special_btn.pressed.connect(_on_special)
	run_btn.pressed.connect(_on_run)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))
	setup_battle()

func setup_battle():
	if GameManager.current_pet.is_empty():
		return
	player_name.text = GameManager.current_pet.name
	player_hp_current = GameManager.current_pet.stats.hp
	player_hp.max_value = player_hp_current
	player_hp.value = player_hp_current
	
	# Create enemy
	enemy = {
		"name": "Wild Greymon",
		"hp": 120,
		"attack": 40,
		"defense": 30
	}
	enemy_name.text = enemy.name
	enemy_hp_current = enemy.hp
	enemy_hp.max_value = enemy.hp
	enemy_hp.value = enemy_hp_current
	
	battle_log.text = "A wild " + enemy.name + " appears!"

func _on_attack():
	if turn != "player":
		return
	var dmg = max(1, GameManager.current_pet.stats.attack - enemy.defense / 2)
	enemy_hp_current -= dmg
	enemy_hp.value = enemy_hp_current
	battle_log.text = GameManager.current_pet.name + " attacks for " + str(dmg) + " damage!"
	if enemy_hp_current <= 0:
		battle_log.text = "Enemy defeated! +50 coins"
		GameManager.coins += 50
		GameManager.friendship += 10
		GameManager.save_state()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
		return
	turn = "enemy"
	await get_tree().create_timer(1).timeout
	enemy_turn()

func enemy_turn():
	var dmg = max(1, enemy.attack - GameManager.current_pet.stats.defense / 2)
	player_hp_current -= dmg
	player_hp.value = player_hp_current
	battle_log.text = enemy.name + " attacks for " + str(dmg) + " damage!"
	if player_hp_current <= 0:
		battle_log.text = "You were defeated!"
		GameManager.current_pet.care_mistakes += 1
		GameManager.save_state()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
		return
	turn = "player"
	battle_log.text = "Your turn!"

func _on_special():
	battle_log.text = "Special attack! (Coming soon)"

func _on_run():
	get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
