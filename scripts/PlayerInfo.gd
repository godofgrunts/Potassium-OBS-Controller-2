extends VBoxContainer

func _ready() -> void:
	$Label.text = self.name + " Tag"

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	$PlayerCharacterOverride.visible = button_pressed

func set_label(player_name : String) -> void:
	$Label.text = player_name + "Tag"