extends VBoxContainer

func _ready():
	$ComInput.connect("text_changed", self, "_com_name_change")
	$ComSocial.connect("text_changed", self, "_com_social_change")
	$ComPronouns.connect("text_changed", self, "_com_pronoun_change")


func _com_name_change(new_text) -> void:
	SignalManager.emit_signal("com_name_changed", self.name, new_text)

func _com_social_change(new_text) -> void:
	SignalManager.emit_signal("com_social_changed", self.name, new_text)
	
func _com_pronoun_change(new_text) -> void:
	SignalManager.emit_signal("com_pronoun_changed", self.name, new_text)
