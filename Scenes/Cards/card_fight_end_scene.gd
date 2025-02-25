extends PanelContainer

class_name CardFightEndScene

signal ContinuePressed

func _on_continue_button_pressed() -> void:
	ContinuePressed.emit()

func SetData(Won : bool, Funds : int, DoneDmg : float, GotDmg : float, NegDmg : float) -> void:
	if (!Won):
		$VBoxContainer/Label.text = "Defeat"
	var text = ""
	if (Won):
		text += "[center][color=#c19200]Funds Earned[/color] : {0}\n".format([Funds])
	else:
		text += "[center][color=#c19200]Funds Earned[/color] : {0}\n".format([0])
	text += "[color=#c19200]Damage Dealt[/color] : {0}\n".format([DoneDmg])
	text += "[color=#c19200]Damage Received [/color]: {0}\n".format([GotDmg])
	text += "[color=#c19200]Damage Negated[/color] : {0}\n".format([NegDmg])
	$VBoxContainer/Label2.text = text
