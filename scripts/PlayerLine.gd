extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.connect("reset_player_lines", self, "reset")
	reset()

func show_players(index : int, line : int) -> void:
	find_node("Padding" + str(index)).visible = true
	var p := find_node("Player" + str(index))
	p.visible = true
	p.set_label("Player " + str((line * 4) - (4 - index)) + " " )

func reset() -> void:
	self.visible = false
	$Player1.visible = false
	$Player2.visible = false
	$Player3.visible = false
	$Player4.visible = false
	$Padding1.visible = false
	$Padding2.visible = false
	$Padding3.visible = false
	$Padding4.visible = false
	$Padding5.visible = true
