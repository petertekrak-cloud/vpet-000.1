extends Control

@onready var storage_list = $StorageList
@onready var transfer_btn = $Buttons/TransferToGameBtn
@onready var store_btn = $Buttons/StoreCurrentBtn
@onready var back_btn = $BackBtn

func _ready():
	transfer_btn.pressed.connect(_on_transfer_to_game)
	store_btn.pressed.connect(_on_store_current)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))
	update_list()

func update_list():
	storage_list.clear()
	for i in range(GameManager.companion_storage.size()):
		var item = GameManager.companion_storage[i]
		var text = item.id
		if item.has("name"):
			text = item.name + " (" + item.get("stage", "") + ")"
		storage_list.add_item(text)
	storage_list.set_item_metadata(storage_list.get_item_count()-1 if storage_list.get_item_count() > 0 else -1, i)

func _on_transfer_to_game():
	var selected = storage_list.get_selected_items()
	if selected.is_empty():
		return
	var idx = selected[0]
	# Find actual index
	if GameManager.transfer_to_game(idx):
		update_list()
		get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn")

func _on_store_current():
	if GameManager.transfer_to_storage():
		update_list()
