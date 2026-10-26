extends Control

@onready var pet_sprite = $PetSprite
@onready var pet_name = $PetName
@onready var hunger_bar = $StatsPanel/HungerBar
@onready var energy_bar = $StatsPanel/EnergyBar
@onready var mood_bar = $StatsPanel/MoodBar
@onready var friendship_label = $StatsPanel/FriendshipLabel
@onready var feed_btn = $MenuPanel/FeedBtn
@onready var train_btn = $MenuPanel/TrainBtn
@onready var battle_btn = $MenuPanel/BattleBtn
@onready var explore_btn = $MenuPanel/ExploreBtn
@onready var scan_btn = $MenuPanel/ScanBtn
@onready var companion_btn = $MenuPanel/CompanionBtn
@onready var age_label = $AgeLabel if has_node("AgeLabel") else null

var bounce_tween: Tween

func _ready():
	GameManager.pet_updated.connect(update_ui)
	feed_btn.pressed.connect(_on_feed)
	train_btn.pressed.connect(_on_train)
	battle_btn.pressed.connect(_on_battle)
	explore_btn.pressed.connect(_on_explore)
	scan_btn.pressed.connect(_on_scan)
	companion_btn.pressed.connect(_on_companion)
	update_ui()
	start_idle_animation()

func start_idle_animation():
	if bounce_tween and bounce_tween.is_valid():
		bounce_tween.kill()
	bounce_tween = create_tween().set_loops()
	bounce_tween.tween_property(pet_sprite, "scale", Vector2(1.05, 0.95), 0.6)
	bounce_tween.tween_property(pet_sprite, "scale", Vector2(0.95, 1.05), 0.6)
	bounce_tween.tween_property(pet_sprite, "scale", Vector2(1.0, 1.0), 0.4)

func update_ui():
	if GameManager.current_pet.is_empty():
		return
	var pet = GameManager.current_pet
	pet_name.text = pet.name + " ★ " + pet.stage
	hunger_bar.value = pet.hunger
	energy_bar.value = pet.energy
	mood_bar.value = pet.mood
	friendship_label.text = "♥ Friendship: " + str(int(pet.friendship))
	
	if age_label:
		var hours = int(pet.age_seconds / 3600)
		var mins = int((pet.age_seconds % 3600) / 60)
		age_label.text = "Age: %dh %dm" % [hours, mins]
	
	# Update sprite based on state
	var sprite_prefix = get_sprite_prefix(pet.id)
	var mood = pet.mood
	var hunger = pet.hunger
	var sprite_state = "idle"
	if hunger < 30:
		sprite_state = "sad"
	elif mood > 80 and hunger > 50:
		sprite_state = "happy"
	
	var sprite_path = "res://art/sprites/" + sprite_prefix + "_" + sprite_state + ".png"
	if ResourceLoader.exists(sprite_path):
		pet_sprite.texture = load(sprite_path)
		pet_sprite.scale = Vector2(1.0, 1.0)
	
	# Color bars based on values
	if hunger < 30:
		hunger_bar.modulate = Color.RED
	elif hunger < 60:
		hunger_bar.modulate = Color.YELLOW
	else:
		hunger_bar.modulate = Color.GREEN
		
	if energy < 30:
		energy_bar.modulate = Color.RED
	elif energy < 60:
		energy_bar.modulate = Color.YELLOW
	else:
		energy_bar.modulate = Color.GREEN
		
	if mood < 30:
		mood_bar.modulate = Color.RED
	elif mood < 60:
		mood_bar.modulate = Color.YELLOW
	else:
		mood_bar.modulate = Color.GREEN
	
	start_idle_animation()

func get_sprite_prefix(pet_id: String) -> String:
	var d = DataManager.get_digimon(pet_id)
	if d.has("sprite_prefix"):
		return d.sprite_prefix
	return pet_id

func _on_feed():
	animate_button(feed_btn)
	get_tree().change_scene_to_file("res://scenes/ui/FeedMenu.tscn")

func _on_train():
	animate_button(train_btn)
	get_tree().change_scene_to_file("res://scenes/training/Training.tscn")

func _on_battle():
	animate_button(battle_btn)
	get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")

func _on_explore():
	animate_button(explore_btn)
	get_tree().change_scene_to_file("res://scenes/explore/Explore.tscn")

func _on_scan():
	animate_button(scan_btn)
	get_tree().change_scene_to_file("res://scenes/scan/Scan.tscn")

func _on_companion():
	animate_button(companion_btn)
	get_tree().change_scene_to_file("res://scenes/companion/CompanionApp.tscn")

func animate_button(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
