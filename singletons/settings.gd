extends Node


var json_file := "res://settings.json"
var json_info := {}


func _ready() -> void:
	load_data(json_file)

func load_data(json_file) -> void:
	json_info.clear()
	var file := File.new()
	file.open(json_file, file.READ)
	var text = file.get_as_text()
	json_info = parse_json(text)
	file.close()

