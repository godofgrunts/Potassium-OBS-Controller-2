extends Tabs

onready var input_settings = $PanelContainer/VBoxContainer/HBoxContainer/Inputs
var custom_settings
var settings := []
var obs_data := {}
var save_data := {}


func _ready() -> void:
	var button = Button.new()
	button.text = "Save All"
	button.self_modulate = Color(1,1,0,1)
	button.name = "SaveButton"
	input_settings.add_child(button)
	_set_up()
	save()
	
	button.connect("pressed", self, "save")

################################################################################
# We're going to get all the options available to the player settings and      #
# set the text boxes equal to the current values                               #
################################################################################
func _set_up() -> void:
	for i in input_settings.get_children():
		if i is LineEdit:
			settings.append(i.name)
	for i in Settings.json_info.information:
		if i.has(self.name):
			for h in settings:
				input_settings.find_node(h).text = i.get(self.name)[h]
		
func save() -> void:
	_get_data()
	save_data.clear()
	save_data[self.name] = obs_data
	SignalManager.emit_signal("settings_changed", self.name, save_data)

func _get_data() -> void:
	obs_data.clear()
	for i in Settings.json_info.information:
		if i.has(self.name):
			for h in settings:
				obs_data[h] = self.find_node(h).text
		
