extends Node

var json_file := "res://info.json"
var user_json_file := "user://custom_info.json"
var json_info
var event_name : String = ""
var shorthand_name : String = ""
var round_name : String = ""
var filename_array : Array = []


func _ready() -> void:
	var file := File.new()
	if file.file_exists(user_json_file):
		json_file = user_json_file
	# warning-ignore:return_value_discarded
	file.open(json_file, file.READ)
	var text = file.get_as_text()
	json_info = parse_json(text)
	file.close()
