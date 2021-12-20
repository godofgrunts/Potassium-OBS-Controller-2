extends VBoxContainer

var override : bool = false
var char_index : int = 0

func _ready() -> void:
# warning-ignore:return_value_discarded
	$PlayerInput.connect("text_changed", self, "_player_name_change")
# warning-ignore:return_value_discarded
	$PlayerSocial.connect("text_changed", self, "_player_social_change")
# warning-ignore:return_value_discarded
	$PlayerPronouns.connect("text_changed", self, "_player_pronoun_change")
# warning-ignore:return_value_discarded
	$PlayerCharacter.connect("item_selected", self, "_player_character_change")
# warning-ignore:return_value_discarded
	$PlayerCharacterOverride.connect("text_changed", self, "_player_character_override_change")

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	$PlayerCharacterOverride.visible = button_pressed
	override = button_pressed
	if not override:
		_player_character_change(char_index)

func set_label(player_name : String) -> void:
	$Label.text = player_name + " Tag"

func _player_name_change(new_text) -> void:
	SignalManager.emit_signal("player_name_changed", self.name, new_text)

func _player_social_change(new_text) -> void:
	SignalManager.emit_signal("player_social_changed", self.name, new_text)

func _player_pronoun_change(new_text) -> void:
	SignalManager.emit_signal("player_pronoun_changed", self.name, new_text)

func _player_character_change(index) -> void:
	char_index = index
	var new_text = $PlayerCharacter.get_item_text(index)
	if not override:
		SignalManager.emit_signal("player_character_changed", self.name, new_text)

func _player_character_override_change(new_text) -> void:
	SignalManager.emit_signal("player_character_override_changed", self.name, new_text)
