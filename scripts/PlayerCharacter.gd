extends OptionButton
var current_game : String = "64"


func _ready() -> void:
	var _signal = SignalManager.connect("game_changed", self, "_on_game_changed")
	populate()

	
func _on_game_changed(game_name):
	current_game = game_name
	populate()

func add_characters():
	for i in Info.json_info["characters"]:
		if i["game"].has(current_game):
			self.add_item(i["name"])

func reset_dropdown():
	for i in self.get_item_count():
		self.remove_item(0)

func populate():
	reset_dropdown()
	add_characters()
