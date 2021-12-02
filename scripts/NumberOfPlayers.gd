extends OptionButton


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_item("", 0)
	for i in range(8):
		self.add_item(str(i + 1), i + 1)
	self.select(2)
