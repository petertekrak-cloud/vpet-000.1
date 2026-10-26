extends Control

@onready var nodes = [$Map/Node1, $Map/Node2, $Map/Node3, $Map/Node4, $Map/Node5, $Map/Node6, $Map/Node7, $Map/Node8]
@onready var event_log = $EventLog
@onready var back_btn = $BackBtn

func _ready():
	for i in range(nodes.size()):
		nodes[i].pressed.connect(func(): explore_area(i))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))

func explore_area(area: int):
	if GameManager.current_pet.is_empty():
		event_log.text = "No Digimon to explore with!"
		return
	var areas = ["Forest", "Cave", "Beach", "Mountain", "Desert", "Glacier", "Volcano", "Factory"]
	event_log.text = "Exploring " + areas[area] + "..."
	await get_tree().create_timer(1).timeout
	# Random encounter
	if randf() < 0.6:
		var rewards = ["Found meat!", "Found coins!", "Battle encounter!"]
		var reward = rewards[randi() % rewards.size()]
		event_log.text = reward
		if reward == "Found meat!":
			GameManager.inventory.meat = GameManager.inventory.get("meat", 0) + 1
		elif reward == "Found coins!":
			GameManager.coins += 20
		elif reward == "Battle encounter!":
			get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")
		GameManager.save_state()
	else:
		event_log.text = "Nothing found this time."
	GameManager.current_pet.friendship += 1
	GameManager.save_state()
