extends Control

@onready var meat_btn = $FoodList/MeatBtn
@onready var bread_btn = $FoodList/BreadBtn
@onready var vitamin_btn = $FoodList/VitaminBtn
@onready var protein_btn = $FoodList/ProteinBtn
@onready var back_btn = $BackBtn

func _ready():
	meat_btn.pressed.connect(func(): feed("meat"))
	bread_btn.pressed.connect(func(): feed("bread"))
	vitamin_btn.pressed.connect(func(): feed("vitamin"))
	protein_btn.pressed.connect(func(): feed("protein"))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))
	update_buttons()

func update_buttons():
	meat_btn.text = "Meat (x" + str(GameManager.inventory.get("meat", 0)) + ") - Hunger +30"
	bread_btn.text = "Bread (x" + str(GameManager.inventory.get("bread", 0)) + ") - Hunger +25"
	vitamin_btn.text = "Vitamin (x" + str(GameManager.inventory.get("vitamin", 0)) + ") - Stats Up"
	protein_btn.text = "Protein (x" + str(GameManager.inventory.get("protein", 0)) + ") - Attack/Defense"

func feed(food_id: String):
	if GameManager.feed_food(food_id):
		update_buttons()
