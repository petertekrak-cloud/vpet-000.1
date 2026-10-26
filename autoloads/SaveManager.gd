extends Node

const SAVE_PATH = "user://digimon_save.json"
const COMPANION_PATH = "user://companion_storage.json"

func save_game(data: Dictionary) -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	return true

func load_game() -> Dictionary:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.parse_string(json_text)
	if json == null:
		return {}
	return json

func save_companion(data: Dictionary) -> bool:
	var file = FileAccess.open(COMPANION_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	return true

func load_companion() -> Dictionary:
	var file = FileAccess.open(COMPANION_PATH, FileAccess.READ)
	if file == null:
		return {}
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.parse_string(json_text)
	if json == null:
		return {}
	return json
