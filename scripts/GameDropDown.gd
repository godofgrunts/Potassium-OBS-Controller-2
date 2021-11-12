extends OptionButton
export (String, FILE) var options


func _ready() -> void:
	var list := File.new()
	var _opened = list.open(options, File.READ)
	while !list.eof_reached():
		self.add_item(list.get_line())
	self.remove_item((self.get_item_count() - 1))
	list.close()
