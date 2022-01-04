extends HBoxContainer


func _ready() -> void:
# warning-ignore:return_value_discarded
	SignalManager.connect("best_of_changed", self, "_on_best_of_changed")
# warning-ignore:return_value_discarded
	$Player1/OptionButton.connect("item_selected", self, "_on_score_change_player1")
# warning-ignore:return_value_discarded
	$Player2/OptionButton.connect("item_selected", self, "_on_score_change_player2")
	_on_best_of_changed(1)

func _on_best_of_changed(max_range) -> void:
	reset_dropdown()
	
# warning-ignore:integer_division
	var half = int(max_range) / 2
	for i in range(0,half + 2):
		$Player1/OptionButton.add_item(str(i))
		$Player2/OptionButton.add_item(str(i))

func _add_numbers(max_range) -> void:
	for i in range(1,max_range):
		if i % 2 != 0:
			$BestOfButton.add_item(str(i))

func reset_dropdown() -> void:
	for i in $Player1/OptionButton.get_item_count():
		$Player1/OptionButton.remove_item(0)
	for i in $Player2/OptionButton.get_item_count():
		$Player2/OptionButton.remove_item(0)

func _on_score_change_player1(index) -> void:
	var new_score = $Player1/OptionButton.get_item_index(index)
	SignalManager.emit_signal("score_changed", "Player1", new_score)

func _on_score_change_player2(index) -> void:
	var new_score = $Player2/OptionButton.get_item_index(index)
	SignalManager.emit_signal("score_changed", "Player2", new_score)
