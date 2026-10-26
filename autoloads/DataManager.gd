extends Node

var digimon_data = {}
var evolution_data = {}
var food_data = {}
var upgrade_data = {}
var scannable_data = {}

func _ready():
	load_all_data()

func load_all_data():
	digimon_data = load_json("res://data/digimon.json")
	evolution_data = load_json("res://data/evolutions.json")
	food_data = load_json("res://data/foods.json")
	upgrade_data = load_json("res://data/digivice_upgrades.json")
	scannable_data = load_json("res://data/scannable.json")

func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Failed to load: ", path)
		return {}
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.parse_string(json_text)
	if json == null:
		return {}
	return json

func get_digimon(id: String) -> Dictionary:
	if digimon_data.has("digimon_list"):
		for d in digimon_data.digimon_list:
			if d.id == id:
				return d
	return {}

func get_food(id: String) -> Dictionary:
	if food_data.has("foods"):
		for f in food_data.foods:
			if f.id == id:
				return f
	return {}
