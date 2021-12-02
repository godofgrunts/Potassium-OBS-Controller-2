extends Node

var json_file := "res://info.json"
var json_info


func _ready() -> void:
	var file := File.new()
	file.open(json_file, file.READ)
	var text = file.get_as_text()
	json_info = parse_json(text)
	file.close()
