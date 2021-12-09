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
	obs_websocket.connect("obs_updated", self, "_on_obs_updated")
	obs_websocket.connect("obs_connected", self, "_on_obs_connected")
	obs_websocket.connect("obs_scene_list_returned", self, "_on_obs_scene_list_returned")
	SignalManager.connect("player_name_changed", self, "_on_player_name_changed")
	SignalManager.connect("player_social_changed", self, "_on_player_social_changed")
	SignalManager.connect("player_pronoun_changed", self, "_on_player_pronoun_changed")
	SignalManager.connect("player_character_changed", self, "_on_player_character_changed")
	SignalManager.connect("player_character_override_changed", self, "_on_player_character_override_changed")
	_on_NumberOfPlayers_item_selected(2)
	SignalManager.emit_signal("main_ready", $ObsWebsocket)
	

func _on_EventNameInput_text_changed(new_text: String) -> void:
	event_name = new_text 


func _on_ShorthandInput_text_changed(new_text: String) -> void:
	shorthand_name = new_text 


func _on_RoundInput_text_changed(new_text: String) -> void:
	round_name = new_text 


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
		1:
			_on_NumberOfPlayers_item_selected(4)
			number_of_players_menu.select(4)

func _on_NumberOfPlayers_item_selected(index: int) -> void:
	SignalManager.emit_signal("reset_player_lines")
	if index == 0:
		$Container/AcceptDialog.show()
	
	# Determine how many PlayerLines to show. If modulate is 0, that means
	# we have all 4 slots, but don't need a new line so we subtract 1.
	
# warning-ignore:integer_division
	var line_count = index / 4
	var modulate_line = index % 4
	print("modulate_line = %s" % modulate_line)
	
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
			

func _on_player_name_changed(source, text) -> void:
	var source_name = source + "Name"
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_social_changed(source, text) -> void:
	var source_name = source + "Social"
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_pronoun_changed(source, text) -> void:
	var source_name = source + "Pronouns"
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_character_changed(source, text) -> void:
	var source_name = source + "Character"
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

func _on_player_character_override_changed(source, text) -> void:
	var source_name = source + "Character"
	obs_websocket.send_command("SetSourceSettings", {"sourceName":source_name, "sourceSettings":{"text":text}})

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
