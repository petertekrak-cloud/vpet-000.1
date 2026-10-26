extends Control

@onready var code_input = $CodeInput
@onready var scan_btn = $ScanBtn
@onready var result_label = $ResultLabel
@onready var back_btn = $BackBtn

func _ready():
	scan_btn.pressed.connect(_on_scan)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/Digivice.tscn"))

func _on_scan():
	var code = code_input.text.strip_edges().to_upper()
	if code.is_empty():
		result_label.text = "Enter a code!"
		return
	var res = GameManager.scan_code(code)
	if res.success:
		result_label.text = "Scanned " + res.digimon_id + "! Added to storage."
	else:
		result_label.text = res.message
	code_input.text = ""
