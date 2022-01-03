extends Tabs

onready var dropdown := $PanelContainer/VBoxContainer/Builder/TextOptions
onready var preview := $PanelContainer/VBoxContainer/Preview

func _ready() -> void:
	var _sig = SignalManager.connect("rebuild_preview", self, "_preview_display")
	dropdown.add_item("Event Name")				# 0
	dropdown.add_item("Shorthand")				# 1
	dropdown.add_item("Round")					# 2
	dropdown.add_item("Game Name")				# 3
	dropdown.add_item("Game Type")				# 4
	dropdown.add_item("Player 1 Name")			# 5
	dropdown.add_item("Player 2 Name")			# 6
	dropdown.add_item("Player 1 Character")		# 7
	dropdown.add_item("Player 2 Character")		# 8
	dropdown.add_item("[")						# 9
	dropdown.add_item("]")						# 10
	dropdown.add_item("(")						# 11
	dropdown.add_item(")")						# 12
	dropdown.add_item("vs")						# 13
	dropdown.add_item("-")						# 14
	_preview_display()

func _preview_builder(option : String, dropdown_item : int = 0):
	match option:
		"add":
			match dropdown_item:
				0:
					Settings.filename_array.append("event_name")
				1:
					Settings.filename_array.append("shorthand_name")
				2:
					Settings.filename_array.append("round_name")
				3:
					Settings.filename_array.append("game_name")
				4:
					Settings.filename_array.append("game_type")
				5:
					Settings.filename_array.append("Player1Name")
				6:
					Settings.filename_array.append("Player2Name")
				7:
					Settings.filename_array.append("Player1Character")
				8:
					Settings.filename_array.append("Player2Character")
				9:
					Settings.filename_array.append("[")
				10:
					Settings.filename_array.append("]")
				11: 
					Settings.filename_array.append("(")
				12:
					Settings.filename_array.append(")")
				13:
					Settings.filename_array.append("vs")
				14:
					Settings.filename_array.append("-")
		"delete":
			Settings.filename_array.pop_back()
		"clear":
			Settings.filename_array.clear()
	SignalManager.emit_signal("filename_array_changed")
	_preview_display()

func _preview_display() -> void:
	preview.text = ""
	for i in Settings.filename_array:
		var prev_text = preview.text
		var new_text
		if prev_text == "":
			new_text = Settings.filename_dict.get(i)
		else:
			new_text = prev_text + " " + Settings.filename_dict.get(i)
		preview.text = new_text

func _on_NextButton_pressed() -> void:
	_preview_builder("add", dropdown.get_selected_id())


func _on_DeleteButton_pressed() -> void:
	_preview_builder("delete")


func _on_ClearButton_pressed() -> void:
	_preview_builder("clear")
