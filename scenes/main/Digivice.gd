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

func _ready():
	GameManager.pet_updated.connect(update_ui)
	feed_btn.pressed.connect(_on_feed)
	train_btn.pressed.connect(_on_train)
	battle_btn.pressed.connect(_on_battle)
	explore_btn.pressed.connect(_on_explore)
	scan_btn.pressed.connect(_on_scan)
	companion_btn.pressed.connect(_on_companion)
	update_ui()

func update_ui():
	if GameManager.current_pet.is_empty():
		return
	var pet = GameManager.current_pet
	pet_name.text = pet.name + " (" + pet.stage + ")"
	hunger_bar.value = pet.hunger
	energy_bar.value = pet.energy
	mood_bar.value = pet.mood
	friendship_label.text = "Friendship: " + str(int(pet.friendship))
	
	# Update sprite based on state
	var sprite_prefix = get_sprite_prefix(pet.id)
	var sprite_path = "res://art/sprites/" + sprite_prefix + "_idle.png"
	if ResourceLoader.exists(sprite_path):
		pet_sprite.texture = load(sprite_path)

func get_sprite_prefix(pet_id: String) -> String:
	var d = DataManager.get_digimon(pet_id)
	if d.has("sprite_prefix"):
		return d.sprite_prefix
	return pet_id

func _on_feed():
	get_tree().change_scene_to_file("res://scenes/ui/FeedMenu.tscn")

func _on_train():
	get_tree().change_scene_to_file("res://scenes/training/Training.tscn")

func _on_battle():
	get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")

func _on_explore():
	get_tree().change_scene_to_file("res://scenes/explore/Explore.tscn")

func _on_scan():
	get_tree().change_scene_to_file("res://scenes/scan/Scan.tscn")

func _on_companion():
	get_tree().change_scene_to_file("res://scenes/companion/CompanionApp.tscn")
