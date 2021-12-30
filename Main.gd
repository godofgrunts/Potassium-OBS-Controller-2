extends CanvasLayer

const MIN_SIZE := Vector2(1280,720)

onready var game_dropdown_menu = find_node("GameDropDown")
onready var gametype_dropdown_menu = find_node("GameTypeOptions")
onready var number_of_players_menu = find_node("NumberOfPlayers")

var obs_websocket : Node
var event_name : String = ""
var shorthand_name : String = ""
var round_name : String = ""
var game_name : String = "64"
var game_type : String = "Singles"

func _ready() -> void:
	OS.min_window_size = MIN_SIZE
	obs_websocket = load("res://addons/obs_websocket_gd/obs_websocket.tscn").instance()
	add_child(obs_websocket)
# warning-ignore:return_value_discarded
	obs_websocket.connect("obs_updated", self, "_on_obs_updated")
# warning-ignore:return_value_discarded
	obs_websocket.connect("obs_connected", self, "_on_obs_connected")
# warning-ignore:return_value_discarded
	obs_websocket.connect("obs_scene_list_returned", self, "_on_obs_scene_list_returned")
# warning-ignore:return_value_discarded
	SignalManager.connect("player_name_changed", self, "_on_player_name_changed")
# warning-ignore:return_value_discarded
	SignalManager.connect("player_social_changed", self, "_on_player_social_changed")
# warning-ignore:return_value_discarded
	SignalManager.connect("player_pronoun_changed", self, "_on_player_pronoun_changed")
# warning-ignore:return_value_discarded
	SignalManager.connect("player_character_changed", self, "_on_player_character_changed")
# warning-ignore:return_value_discarded
	SignalManager.connect("player_character_override_changed", self, "_on_player_character_override_changed")
# warning-ignore:return_value_discarded
	SignalManager.connect("score_changed", self, "_on_player_score_changed")
	_on_NumberOfPlayers_item_selected(2)
	SignalManager.emit_signal("main_ready", $ObsWebsocket)
	


func _get_player_source_name(source, setting) -> String:
	var source_name
	var players = Settings.json_info["players"]
	for i in range(players.size()):
		if players[i].has(source):
			source_name = players[i].get(source).get(setting)
	return source_name
	
func _get_info_source_name(setting) -> String:
	var source_name
	for i in Settings.json_info["information"]:
		if i.has("Video"):
			source_name = i["Video"].get(setting)
	return source_name
			

func _on_player_name_changed(source, text) -> void:
	var source_name = _get_player_source_name(source, "obs_name")
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_social_changed(source, text) -> void:
	var source_name = _get_player_source_name(source, "social")
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_pronoun_changed(source, text) -> void:
	var source_name = _get_player_source_name(source, "pronouns")
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_character_changed(source, text) -> void:
	var source_name = _get_player_source_name(source, "character")
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_character_override_changed(source, text) -> void:
	var source_name = _get_player_source_name(source, "character")
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_score_changed(source, score) -> void:
	var source_name = _get_player_source_name(source, "score")
	var text = str(score)
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_EventNameInput_text_changed(new_text: String) -> void:
	var source_name : String = _get_info_source_name("eventname")
	Info.event_name = new_text 
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":Info.event_name}})

func _on_ShorthandInput_text_changed(new_text: String) -> void:
	var source_name : String = _get_info_source_name("shorthand")
	Info.shorthand_name = new_text 
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":Info.shorthand_name}})

func _on_RoundInput_text_changed(new_text: String) -> void:
	var source_name : String = _get_info_source_name("round")
	Info.round_name = new_text 
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":Info.round_name}})

func _on_GameDropDown_item_selected(index: int) -> void:
	game_name = game_dropdown_menu.get_item_text(index)
	SignalManager.emit_signal("game_changed", game_name)

func _on_GameTypeOptions_item_selected(index: int) -> void:
	### INDEX REFERENCE
	### 0: Singles
	### 1: Doubles
	### 2: Squad Strike
	### 3: Frindlies
	### 4: Casuals
	game_type = gametype_dropdown_menu.get_item_text(index)
	match index:
		0:
			_on_NumberOfPlayers_item_selected(2)
			number_of_players_menu.select(2)
			$TabContainer/Main/PanelContainer/VBoxContainer/ScoreLine/Player1/Label.text = "Player 1 Wins"
			$TabContainer/Main/PanelContainer/VBoxContainer/ScoreLine/Player2/Label.text = "Player 2 Wins"
		1:
			_on_NumberOfPlayers_item_selected(4)
			number_of_players_menu.select(4)
			$TabContainer/Main/PanelContainer/VBoxContainer/ScoreLine/Player1/Label.text = "Team 1 Wins"
			$TabContainer/Main/PanelContainer/VBoxContainer/ScoreLine/Player2/Label.text = "Team 2 Wins"

func _on_NumberOfPlayers_item_selected(index: int) -> void:
	SignalManager.emit_signal("reset_player_lines")
	if index == 0:
		$Container/AcceptDialog.show()
	
	# Determine how many PlayerLines to show. If modulate is 0, that means
	# we have all 4 slots, but don't need a new line so we subtract 1.
	
# warning-ignore:integer_division
	var line_count = index / 4
	var modulate_line = index % 4
	
	if modulate_line != 0:
		line_count = line_count + 1
	
	for i in range(1,line_count+1):
		var line_temp = "PlayerLine" + str(i)
		var line = find_node(line_temp)
		line.visible = true
		
		for k in range((i*4)-3,index+1):
			if k > 4:
				k = k - 4
			line.show_players(k, i)

func _on_obs_updated(data) -> void:
	pass
	
func _on_obs_connected() -> void:
	print("connected")
	
func _on_obs_scene_list_returned() -> void:
	pass
	




###############################################################################
# Testing Area                                                                #
###############################################################################

var command : String = "StartRecording"
var command_dict : = {}

func _on_temp_Button_pressed():
	obs_websocket.send_command(command, command_dict)


func _on_SendCommandInfo_text_entered(new_text):
	command = new_text
	print(command)



func _on_OptionalLines_text_entered(new_text):
	command_dict = parse_json(new_text)
	print(command_dict)
