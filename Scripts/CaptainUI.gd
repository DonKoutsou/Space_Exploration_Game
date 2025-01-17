extends PanelContainer
class_name CaptainUI

@export var DroneDockEvH : DroneDockEventHandler
@export var CaptainStatpScene : PackedScene
@export var EmptySlotScene : PackedScene

var Drones : Array[Drone]

func _ready() -> void:
	DroneDockEvH.connect("DroneAdded", AddCaptain)

func AddCaptain(Dr : Drone, _Target : MapShip):
	var Position : Control
	for g in $GridContainer.get_children():
		if (g is CaptainPanel):
			continue
		Position = g
		Position.get_child(0).free()
		break
	Drones.append(Dr)
	var cptscene = CaptainStatpScene.instantiate() as CaptainPanel
	cptscene.connect("OnCaptainDischarged", OnCaptainDischarged)
	Position.replace_by(cptscene)
	Position.free()
	cptscene.SetCap(Dr.Cpt)

func ToggleUI(t : bool) -> void:
	position.x = 0
	Map.GetInstance().OnScreenUiToggled(t)
func _on_captain_button_pressed() -> void:
	position.x = 0
	if (!visible):
		Map.GetInstance().OnScreenUiToggled(false)
		$"../InventoryUI".visible = false
	else:
		Map.GetInstance().OnScreenUiToggled(true)
	visible = !visible

func OnCaptainDischarged(C : Captain):
	for g in $GridContainer.get_children():
		if (g is CaptainPanel):
			if (g.Capt == C):
				g.queue_free()
				break
	for g in Drones:
		if (g.Cpt == C):
			DroneDockEvH.OnDroneDischarged(g)
			$GridContainer.add_child(EmptySlotScene.instantiate())
			return


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and Input.is_action_pressed("Click")):
		var rel = event.relative
		position.x = clamp(position.x + rel.x, - size.x + get_viewport_rect().size.x, 0)
