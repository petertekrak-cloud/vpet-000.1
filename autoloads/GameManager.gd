extends Node

signal pet_updated
signal time_tick

var current_pet = {}
var inventory = {"meat": 8, "bread": 5, "vitamin": 2, "protein": 3}
var digivice_tier = 1
var unlocked_upgrades = ["basic"]
var scanned_codes = []
var companion_storage = []
var coins = 500
var last_save_time = 0

var game_time = 0
var time_accumulator = 0

func _ready():
	load_state()

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= 1.0:
		time_accumulator = 0
		game_time += 1
		process_time()
		emit_signal("time_tick")

func process_time():
	if current_pet.is_empty():
		return
	var hunger_rate = 0.3
	var energy_rate = 0.2
	current_pet.hunger = max(0, current_pet.hunger - hunger_rate)
	current_pet.energy = max(0, current_pet.energy - energy_rate)
	
	if current_pet.hunger < 25 or current_pet.energy < 25:
		current_pet.mood = max(0, current_pet.mood - 0.15)
		if randf() < 0.01:
			current_pet.care_mistakes += 1
	elif current_pet.hunger > 70 and current_pet.energy > 70:
		current_pet.mood = min(100, current_pet.mood + 0.08)
	
	current_pet.age_seconds += 1
	if current_pet.fatigue > 0:
		current_pet.fatigue = max(0, current_pet.fatigue - 0.5)
	
	emit_signal("pet_updated")
	check_evolution()
	
	if game_time % 60 == 0:
		save_state()

func create_new_pet(digimon_id: String = "botamon") -> void:
	var d = DataManager.get_digimon(digimon_id)
	if d.is_empty():
		return
	current_pet = {
		"id": digimon_id,
		"name": d.name,
		"stage": d.stage,
		"base_stats": d.base_stats.duplicate(),
		"stats": {"hp": d.base_stats.hp, "attack": d.base_stats.attack, "defense": d.base_stats.defense, "speed": d.base_stats.speed},
		"hunger": 100,
		"energy": 100,
		"mood": 100,
		"weight": 10,
		"friendship": 0,
		"care_mistakes": 0,
		"training_count": 0,
		"age_seconds": 0,
		"fatigue": 0,
		"sleeping": false,
		"sick": false,
		"last_fed": game_time,
		"last_trained": game_time
	}
	emit_signal("pet_updated")
	save_state()

func feed_food(food_id: String) -> bool:
	if inventory.get(food_id, 0) <= 0:
		return false
	var food = DataManager.get_food(food_id)
	if food.is_empty():
		return false
	
	inventory[food_id] -= 1
	current_pet.hunger = min(100, current_pet.hunger + food.hunger_restore)
	current_pet.weight += food.weight_change
	current_pet.mood = min(100, current_pet.mood + food.mood_change)
	
	if food.has("stat_effects"):
		for stat in food.stat_effects:
			if current_pet.stats.has(stat):
				current_pet.stats[stat] += food.stat_effects[stat]
	
	current_pet.friendship += 3
	emit_signal("pet_updated")
	save_state()
	return true

func train(stat_type: String) -> Dictionary:
	if current_pet.fatigue >= 100:
		return {"success": false, "message": "Too tired to train!"}
	if current_pet.energy < 15:
		return {"success": false, "message": "Not enough energy!"}
	
	var gain = randi_range(2, 4)
	current_pet.stats[stat_type] += gain
	current_pet.training_count += 1
	current_pet.fatigue += 12
	current_pet.energy -= 18
	current_pet.friendship += 5
	current_pet.mood = min(100, current_pet.mood + 8)
	
	emit_signal("pet_updated")
	save_state()
	return {"success": true, "gain": gain, "stat": stat_type}

func check_evolution():
	if current_pet.is_empty():
		return
	var evols = DataManager.evolution_data.get("evolutions", [])
	for evo in evols:
		if evo.from == current_pet.id:
			if can_evolve(evo):
				do_evolution(evo)
				break

func can_evolve(evo: Dictionary) -> bool:
	var req = evo.requirements
	if req.has("min_age_hours"):
		if current_pet.age_seconds < req.min_age_hours * 3600:
			return false
	if req.has("min_friendship"):
		if current_pet.friendship < req.min_friendship:
			return false
	if req.has("min_care_mistakes"):
		if current_pet.care_mistakes < req.min_care_mistakes:
			return false
	if req.has("max_care_mistakes"):
		if current_pet.care_mistakes > req.max_care_mistakes:
			return false
	if req.has("training_count_min"):
		if current_pet.training_count < req.training_count_min:
			return false
	if req.has("min_stats"):
		for stat in req.min_stats:
			if current_pet.stats.get(stat, 0) < req.min_stats[stat]:
				return false
	return true

func do_evolution(evo: Dictionary):
	var new_id = evo.to
	var d = DataManager.get_digimon(new_id)
	if d.is_empty():
		return
	current_pet.id = new_id
	current_pet.name = d.name
	current_pet.stage = d.stage
	for stat in current_pet.stats:
		current_pet.stats[stat] = int(current_pet.stats[stat] * 1.25) + int(d.base_stats.get(stat, 0) / 3)
	current_pet.friendship += 25
	current_pet.mood = 100
	emit_signal("pet_updated")
	save_state()

func scan_code(code: String) -> Dictionary:
	var scannables = DataManager.scannable_data.get("scannable", [])
	for s in scannables:
		if s.code == code:
			if s.tier_required > digivice_tier:
				return {"success": false, "message": "Digivice tier too low!"}
			if code in scanned_codes:
				return {"success": false, "message": "Already scanned!"}
			scanned_codes.append(code)
			var new_digimon = {
				"id": s.digimon_id,
				"scanned_at": Time.get_unix_time_from_system(),
				"level": 1
			}
			companion_storage.append(new_digimon)
			save_companion_storage()
			save_state()
			return {"success": true, "digimon_id": s.digimon_id}
	return {"success": false, "message": "Invalid code!"}

func upgrade_digivice(upgrade_id: String) -> bool:
	var upgrades = DataManager.upgrade_data.get("upgrades", [])
	for u in upgrades:
		if u.id == upgrade_id and u.tier > digivice_tier:
			if coins >= u.cost:
				coins -= u.cost
				digivice_tier = u.tier
				unlocked_upgrades.append(upgrade_id)
				save_state()
				return true
	return false

func transfer_to_game(storage_index: int) -> bool:
	if storage_index < 0 or storage_index >= companion_storage.size():
		return false
	var digimon_ref = companion_storage[storage_index]
	create_new_pet(digimon_ref.id)
	companion_storage.remove_at(storage_index)
	save_companion_storage()
	save_state()
	return true

func transfer_to_storage() -> bool:
	if current_pet.is_empty():
		return false
	var storage_entry = {
		"id": current_pet.id,
		"name": current_pet.name,
		"stage": current_pet.stage,
		"stats": current_pet.stats.duplicate(),
		"friendship": current_pet.friendship,
		"stored_at": Time.get_unix_time_from_system()
	}
	companion_storage.append(storage_entry)
	save_companion_storage()
	current_pet = {}
	save_state()
	return true

func save_companion_storage():
	var data = {"storage": companion_storage}
	SaveManager.save_companion(data)

func save_state():
	var data = {
		"current_pet": current_pet,
		"inventory": inventory,
		"digivice_tier": digivice_tier,
		"unlocked_upgrades": unlocked_upgrades,
		"scanned_codes": scanned_codes,
		"coins": coins,
		"game_time": game_time
	}
	SaveManager.save_game(data)

func load_state():
	var data = SaveManager.load_game()
	if data.is_empty():
		create_new_pet("botamon")
		return
	current_pet = data.get("current_pet", {})
	inventory = data.get("inventory", inventory)
	digivice_tier = data.get("digivice_tier", 1)
	unlocked_upgrades = data.get("unlocked_upgrades", ["basic"])
	scanned_codes = data.get("scanned_codes", [])
	coins = data.get("coins", 500)
	game_time = data.get("game_time", 0)
	
	var comp_data = SaveManager.load_companion()
	if comp_data.has("storage"):
		companion_storage = comp_data.storage
