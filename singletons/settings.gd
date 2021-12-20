extends Node


var json_file := "res://settings.json"
var user_json_file := "user://custom_settings.json"
var json_info := {}

var temp_dict := {}
var player_structure := []
var information_structure := []
var obs_structure := []


func _ready() -> void:
# warning-ignore:return_value_discarded
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	var file = File.new()
	if file.file_exists(user_json_file):
		json_file = user_json_file
	file.close()
	load_data()

func load_data() -> void:
	json_info.clear()
	var file := File.new()
# warning-ignore:return_value_discarded
	file.open(json_file, file.READ)
	var text = file.get_as_text()
	json_info = parse_json(text)
	player_structure = json_info["players"]
	information_structure = json_info["information"]
	obs_structure = json_info["obs"]
	file.close()

func _on_settings_changed(source, dict) -> void:
	_setting_loop(source, dict, player_structure)
	_setting_loop(source, dict, information_structure)
	_setting_loop(source, dict, obs_structure)

func _setting_loop(source, dict, array_to_check) -> void:
	for i in range(array_to_check.size()):
		if array_to_check[i].has(source):
			array_to_check[i] = dict
	_set_json_array()

func _set_json_array() -> void:
	temp_dict.clear()
	temp_dict["players"] = player_structure
	temp_dict["information"] = information_structure
	temp_dict["obs"] = obs_structure
	_save_data(temp_dict)
	
func _save_data(dict) -> void:
	json_file = user_json_file
	var file := File.new()
# warning-ignore:return_value_discarded
	file.open(json_file, File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	load_data()
