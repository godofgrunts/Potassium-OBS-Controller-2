extends Node


var json_file := "res://settings.json"
var user_json_file := "user://custom_settings.json"
var json_info := {}

var temp_dict := {}
var player_structure := []
var information_structure := []
var obs_structure := []

var event_name : String = "Event" setget _event_changed
var shorthand_name : String = "ShortHand" setget _shorthand_changed
var round_name : String = "Round" setget _round_changed
var game_name : String = "64" setget _game_name_changed
var game_type : String = "Singles" setget _game_type_changed
const LEFT_BRACKET : String = "["
const RIGHT_BRACKET : String = "]"
const LEFT_PAR : String = "("
const RIGHT_PAR : String = ")"
const VERSUS : String = "vs"
var player_names : = {} setget _player_names_changed
var player_characters : = {} setget _player_characters_changed
var filename_array : Array = []
var filename_dict : = {"[":"[","]":"]","(":"(",")":")","vs":"vs","-":"-"}


func _ready() -> void:
# warning-ignore:return_value_discarded
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	# warning-ignore:return_value_discarded
	SignalManager.connect("filename_array_changed", self, "_file_name_save_and_cleanup")
	var file = File.new()
	if file.file_exists(user_json_file):
		json_file = user_json_file
	file.close()
	load_data()
	player_structure = json_info["players"]
	obs_structure = json_info["obs"]
	information_structure = json_info["information"]
	filename_array = ((information_structure[1]).File.filename)
	filename_dict["Player1Name"] = "Player1"
	filename_dict["Player2Name"] = "Player2"
	filename_dict["Player1Character"] = "P1 Char"
	filename_dict["Player2Character"] = "P2 Char"
	filename_dict["event_name"] = event_name
	filename_dict["shorthand_name"] = shorthand_name
	filename_dict["round_name"] = round_name
	filename_dict["game_name"] = game_name
	filename_dict["game_type"] = game_type

func load_data() -> void:
	json_info.clear()
	var file := File.new()
# warning-ignore:return_value_discarded
	file.open(json_file, file.READ)
	var text = file.get_as_text()
	file.close()
	json_info = parse_json(text)


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

func _event_changed(new_value) -> void:
	event_name = new_value
	filename_dict["event_name"] = event_name
	_file_name_save_and_cleanup()

func _shorthand_changed(new_value) -> void:
	shorthand_name = new_value
	filename_dict["shorthand_name"] = shorthand_name
	_file_name_save_and_cleanup()

func _round_changed(new_value) -> void:
	round_name = new_value
	filename_dict["round_name"] = round_name
	_file_name_save_and_cleanup()

func _game_name_changed(new_value) -> void:
	game_name = new_value
	filename_dict["game_name"] = game_name
	_file_name_save_and_cleanup()

func _game_type_changed(new_value) -> void:
	game_type = new_value
	filename_dict["game_type"] = game_type
	_file_name_save_and_cleanup()

func _player_names_changed(new_value) -> void:
	player_names = new_value
	if player_names.has("Player1Name"):
		filename_dict["Player1Name"] = player_names.Player1Name
	if player_names.has("Player2Name"):
		filename_dict["Player2Name"] = player_names.Player2Name
	_file_name_save_and_cleanup()

func _player_characters_changed(new_value):
	player_characters = new_value
	if player_characters.has("Player1Character"):
		filename_dict["Player1Character"] = player_characters.Player1Character
	if player_characters.has("Player2Character"):
		filename_dict["Player2Character"] = player_characters.Player2Character
	_file_name_save_and_cleanup()

func _file_name_save_and_cleanup() -> void:
	var temp_dict_filename = {"File":{"filename":filename_array}}
	SignalManager.emit_signal("rebuild_preview")
	_on_settings_changed("File", temp_dict_filename)
