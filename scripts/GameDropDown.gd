extends OptionButton
export (String) var data_type


func _ready() -> void:
	for i in Info.json_info[data_type]:
		self.add_item(i)
	
