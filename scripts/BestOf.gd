extends VBoxContainer

enum ranges {NORMAL=8,EXTENDED=102}

func _ready() -> void:
	reset_dropdown()
	_add_numbers(ranges.NORMAL)


func _on_CheckBox_toggled(button_pressed : bool):
	reset_dropdown()
	if button_pressed:
		_add_numbers(ranges.EXTENDED)
	if not button_pressed:
		_add_numbers(ranges.NORMAL)

func _add_numbers(max_range) -> void:
	for i in range(1,max_range):
		if i % 2 != 0:
			$BestOfButton.add_item(str(i))

func reset_dropdown():
	for i in $BestOfButton.get_item_count():
		$BestOfButton.remove_item(0)


func _on_BestOfButton_item_selected(index):
	SignalManager.emit_signal("best_of_changed", $BestOfButton.get_item_text(index))
