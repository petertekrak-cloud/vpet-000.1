extends Control

@onready var player_name = $PlayerSide/PlayerName
@onready var player_hp = $PlayerSide/PlayerHPBar
@onready var player_hp_label = $PlayerSide/PlayerHPLabel
@onready var player_sprite = $PlayerSide/PlayerSprite
@onready var enemy_name = $EnemySide/EnemyName
@onready var enemy_hp = $EnemySide/EnemyHPBar
@onready var enemy_hp_label = $EnemySide/EnemyHPLabel
@onready var enemy_sprite = $EnemySide/EnemySprite
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
	player_hp_label.text = str(player_hp_current) + "/" + str(player_hp_current)
	
	var sprite_prefix = get_sprite_prefix(GameManager.current_pet.id)
	var path = "res://art/sprites/" + sprite_prefix + "_battle.png"
	if !ResourceLoader.exists(path):
		path = "res://art/sprites/" + sprite_prefix + "_idle.png"
	if ResourceLoader.exists(path):
		player_sprite.texture = load(path)
	
	# Create enemy
	enemy = {
		"name": "Wild Greymon",
		"hp": 120,
		"attack": 40,
		"defense": 30,
		"id": "greymon"
	}
	enemy_name.text = enemy.name
	enemy_hp_current = enemy.hp
	enemy_hp.max_value = enemy.hp
	enemy_hp.value = enemy_hp_current
	enemy_hp_label.text = str(enemy_hp_current) + "/" + str(enemy.hp)
	
	var epath = "res://art/sprites/greymon_idle.png"
	if ResourceLoader.exists(epath):
		enemy_sprite.texture = load(epath)
	
	battle_log.text = "⚡ A wild " + enemy.name + " appears!"
	
	# Animation
	player_sprite.scale = Vector2(1.2, 1.2)
	var t = create_tween()
	t.tween_property(player_sprite, "scale", Vector2(1.0, 1.0), 0.3)

func get_sprite_prefix(pet_id: String) -> String:
	var d = DataManager.get_digimon(pet_id)
	if d.has("sprite_prefix"):
		return d.sprite_prefix
	return pet_id

func _on_attack():
	if turn != "player":
		return
	var atk = GameManager.current_pet.stats.attack
	var def = enemy.defense
	var dmg = max(1, int(atk - def / 2))
	dmg += randi_range(0, 5)
	enemy_hp_current -= dmg
	enemy_hp.value = enemy_hp_current
	enemy_hp_label.text = str(max(0, enemy_hp_current)) + "/" + str(enemy.hp)
	
	# Attack animation
	var t = create_tween()
	t.tween_property(player_sprite, "position:x", player_sprite.position.x + 20, 0.1)
	t.tween_property(player_sprite, "position:x", player_sprite.position.x, 0.1)
	
	battle_log.text = "💥 " + GameManager.current_pet.name + " attacks for " + str(dmg) + " damage!"
	if enemy_hp_current <= 0:
		battle_log.text = "🎉 Enemy defeated! +50 coins, +15 friendship!"
		GameManager.coins += 50
		GameManager.current_pet.friendship += 15
		GameManager.save_state()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
		return
	turn = "enemy"
	attack_btn.disabled = true
	special_btn.disabled = true
	run_btn.disabled = true
	await get_tree().create_timer(0.8).timeout
	enemy_turn()

func enemy_turn():
	var atk = enemy.attack
	var def = GameManager.current_pet.stats.defense
	var dmg = max(1, int(atk - def / 2))
	dmg += randi_range(0, 3)
	player_hp_current -= dmg
	player_hp.value = player_hp_current
	player_hp_label.text = str(max(0, player_hp_current)) + "/" + str(int(player_hp.max_value))
	
	var t = create_tween()
	t.tween_property(enemy_sprite, "position:x", enemy_sprite.position.x - 20, 0.1)
	t.tween_property(enemy_sprite, "position:x", enemy_sprite.position.x, 0.1)
	
	battle_log.text = "⚡ " + enemy.name + " attacks for " + str(dmg) + " damage!"
	if player_hp_current <= 0:
		battle_log.text = "💀 You were defeated! Care mistake +1"
		GameManager.current_pet.care_mistakes += 1
		GameManager.save_state()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
		return
	turn = "player"
	attack_btn.disabled = false
	special_btn.disabled = false
	run_btn.disabled = false
	battle_log.text = "⚡ Your turn!"

func _on_special():
	if turn != "player":
		return
	var dmg = int(GameManager.current_pet.stats.attack * 1.5)
	enemy_hp_current -= dmg
	enemy_hp.value = enemy_hp_current
	enemy_hp_label.text = str(max(0, enemy_hp_current)) + "/" + str(enemy.hp)
	battle_log.text = "🔥 SPECIAL ATTACK! " + str(dmg) + " damage!"
	if enemy_hp_current <= 0:
		battle_log.text = "🎉 Enemy defeated! +75 coins!"
		GameManager.coins += 75
		GameManager.current_pet.friendship += 20
		GameManager.save_state()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
		return
	turn = "enemy"
	attack_btn.disabled = true
	special_btn.disabled = true
	run_btn.disabled = true
	await get_tree().create_timer(0.8).timeout
	enemy_turn()

func _on_run():
	var t = create_tween()
	t.tween_property($".", "modulate:a", 0, 0.3)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")
