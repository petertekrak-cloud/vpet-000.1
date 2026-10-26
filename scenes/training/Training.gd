extends Control

@onready var hp_label = $Stats/HPLabel
@onready var atk_label = $Stats/AtkLabel
@onready var def_label = $Stats/DefLabel
@onready var spd_label = $Stats/SpdLabel
@onready var fatigue_label = $Stats/FatigueLabel
@onready var friendship_label = $Stats/FriendshipLabel
@onready var train_atk = $TrainMenu/TrainAtkBtn
@onready var train_def = $TrainMenu/TrainDefBtn
@onready var train_spd = $TrainMenu/TrainSpdBtn
@onready var result_label = $ResultLabel
@onready var back_btn = $BackBtn
@onready var pet_sprite = $PetSprite

func _ready():
	train_atk.pressed.connect(func(): train_stat("attack"))
	train_def.pressed.connect(func(): train_stat("defense"))
	train_spd.pressed.connect(func(): train_stat("speed"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))
	update_ui()
	start_sprite_anim()

func start_sprite_anim():
	var t = create_tween().set_loops()
	t.tween_property(pet_sprite, "position:y", pet_sprite.position.y - 5, 0.4)
	t.tween_property(pet_sprite, "position:y", pet_sprite.position.y, 0.4)

func update_ui():
	if GameManager.current_pet.is_empty():
		return
	var stats = GameManager.current_pet.stats
	hp_label.text = "❤️ HP: " + str(stats.hp)
	atk_label.text = "⚔️ Attack: " + str(stats.attack)
	def_label.text = "🛡️ Defense: " + str(stats.defense)
	spd_label.text = "💨 Speed: " + str(stats.speed)
	fatigue_label.text = "😓 Fatigue: " + str(GameManager.current_pet.fatigue) + "/100"
	friendship_label.text = "♥ Friendship: " + str(int(GameManager.current_pet.friendship))
	
	if GameManager.current_pet.fatigue >= 100:
		fatigue_label.modulate = Color.RED
	elif GameManager.current_pet.fatigue >= 70:
		fatigue_label.modulate = Color.YELLOW
	else:
		fatigue_label.modulate = Color.WHITE
	
	var sprite_prefix = get_sprite_prefix(GameManager.current_pet.id)
	var path = "res://art/sprites/" + sprite_prefix + "_train.png"
	if !ResourceLoader.exists(path):
		path = "res://art/sprites/" + sprite_prefix + "_idle.png"
	if ResourceLoader.exists(path) and pet_sprite:
		pet_sprite.texture = load(path)

func get_sprite_prefix(pet_id: String) -> String:
	var d = DataManager.get_digimon(pet_id)
	if d.has("sprite_prefix"):
		return d.sprite_prefix
	return pet_id

func train_stat(stat: String):
	if GameManager.current_pet.fatigue >= 100:
		result_label.text = "😓 Too exhausted to train!"
		result_label.modulate = Color.RED
		return
	if GameManager.current_pet.energy < 15:
		result_label.text = "⚡ Not enough energy!"
		result_label.modulate = Color.RED
		return
	
	var res = GameManager.train(stat)
	if res.success:
		result_label.text = "✨ +" + str(res.gain) + " to " + res.stat.to_upper() + "!"
		result_label.modulate = Color.GREEN
		# Flash animation
		var t = create_tween()
		t.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.1)
		t.tween_property(result_label, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		result_label.text = res.message
		result_label.modulate = Color.RED
	update_ui()
