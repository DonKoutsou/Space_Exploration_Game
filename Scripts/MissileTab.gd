extends Control
class_name MissileTab

var Armed = false
@export var MissileDockEventH : MissileDockEventHandler
@export var DroneDockEventH : DroneDockEventHandler
#var Missiles : Array[MissileItem]

var CurrentlySelectedMissile

var SelectedIndex : int

var ConnectedShip : MapShip

var Missiles : Dictionary

var AvailableMissiles : Array[MissileItem]

func UpdateConnectedShip(Ship : MapShip) -> void:
	if (!Missiles.has(Ship)):
		var MissileAr : Array[MissileItem] = []
		Missiles[Ship] = MissileAr
	if (Armed):
		_on_dissarm_drone_button_2_pressed()
	ConnectedShip = Ship
	call_deferred("UpdateCrewSelect")

func _ready() -> void:
	DroneDockEventH.connect("DroneAdded", RegisterShip)
	MissileDockEventH.connect("MissileAdded", MissileAdded)
	MissileDockEventH.connect("MissileRemoved", MissileRemoved)
	$Control/Control/Dissarm.ToggleDissable(true)
	$Control/Control/Launch.ToggleDissable(true)
	#visible = false

func FindOwner(Mis : MissileItem) -> Captain:
	for g in Missiles.keys():
		if (Missiles[g].has(Mis)):
			return g.Cpt
	return null
	
	
var d = 0.3

func _physics_process(delta: float) -> void:
	d -= delta
	if (d > 0):
		return
	d = 0.3
	
	UpdateAvailableMissiles()
	
func RegisterShip(Dr : Drone, _Target : MapShip):
	if (!Missiles.has(Dr)):
		var MissileAr : Array[MissileItem] = []
		Missiles[Dr] = MissileAr

func FindShip(C: Captain ) -> MapShip:
	for g in Missiles.keys():
		var ship = g as MapShip
		if (ship.Cpt == C):
			return ship
	return null

func UpdateAvailableMissiles() -> void:
	var sizeb = AvailableMissiles.size()
	var Misses : Array[MissileItem] = []
	Misses.append_array(Missiles[ConnectedShip])
	for g in ConnectedShip.GetDroneDock().DockedDrones:
		Misses.append_array(Missiles[g])
	AvailableMissiles =  Misses
	var sizea = AvailableMissiles.size()
	if (sizeb != sizea):
		UpdateCrewSelect()
	
func MissileAdded(MIs : MissileItem, Target : Captain) -> void:
	var Ship = FindShip(Target)
	if (MIs.Type == 1):
		return
	if (Ship == null):
		call_deferred("MissileAdded",MIs, Target)
		return
	Missiles[Ship].append(MIs)
	if (CurrentlySelectedMissile == null):
		UpdateCrewSelect()

func MissileRemoved(MIs : MissileItem, Target : Captain) -> void:
	var Ship = FindShip(Target)
	if (MIs.Type == 1):
		return
	Missiles[Ship].erase(MIs)
	if (MIs == CurrentlySelectedMissile):
		CurrentlySelectedMissile = null
		UpdateCrewSelect()
		
func _on_deploy_drone_button_pressed() -> void:
	MissileDockEventH.OnMissileLaunched(CurrentlySelectedMissile, FindOwner(CurrentlySelectedMissile),ConnectedShip.Cpt)
	_on_dissarm_drone_button_2_pressed()
	
func _on_arm_drone_button_pressed(t : bool) -> void:
	if (AvailableMissiles.size() == 0):
		_on_dissarm_drone_button_2_pressed()
		return
	if (!t):
		_on_dissarm_drone_button_2_pressed()
		return
	Armed = true
	#$Control/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer3/HBoxContainer2/ArmDroneButton.disabled = true
	$Control/Control/Dissarm.ToggleDissable(false)
	$Control/Control/Launch.ToggleDissable(false)

	MissileDockEventH.MissileArmed(CurrentlySelectedMissile, ConnectedShip.Cpt)
	
func _on_dissarm_drone_button_2_pressed() -> void:
	Armed = false
	$Control/Control/Arm.button_pressed = false
	$Control/Control/Dissarm.ToggleDissable(true)
	$Control/Control/Launch.ToggleDissable(true)
	MissileDockEventH.MissileDissarmed(ConnectedShip.Cpt)

func _on_toggle_drone_tab_pressed() -> void:
	$Control/TouchStopper.mouse_filter = MOUSE_FILTER_IGNORE
	$AnimationPlayer.play("Show")
	UpdateCrewSelect()
		
var SteeringDir : float = 0.0

func UpdateSteer(RelativeRot : float):
	if (Armed):
		SteeringDir = RelativeRot
		MissileDockEventH.MissileDirectionChanged(SteeringDir / 50, ConnectedShip.Cpt)

func UpdateSelected(Dir : bool) -> void:
	if (!Armed):
		ProgressCrewSelect(Dir)

func UpdateCrewSelect(Select : int = 0):
	if (AvailableMissiles.size() > Select):
		SelectedIndex = Select
		CurrentlySelectedMissile = AvailableMissiles[Select]
		$Control/TextureRect/Label2.text = CurrentlySelectedMissile.ItemName
		$Control/Control/Label.text = "Range : " + var_to_str(CurrentlySelectedMissile.Distance) + "km"
		$Control/TextureRect/Light.Toggle(true, true)
	else:
		$Control/TextureRect/Label2.text = "No Missiles"
		$Control/TextureRect/Light.Toggle(true)
		
func ProgressCrewSelect(Front : bool = true):
	if (AvailableMissiles.size() == 0):
		$Control/TextureRect/Label2.text = "No Missiles"
		$Control/TextureRect/Light.Toggle(true)
		return
	if (CurrentlySelectedMissile == null):
		CurrentlySelectedMissile = AvailableMissiles[0]
	else:
		if (Front):
			SelectedIndex +=  1
		else :
			SelectedIndex -= 1
		if (SelectedIndex >= AvailableMissiles.size()):
			SelectedIndex = 0
		else : if (SelectedIndex < 0):
			SelectedIndex = AvailableMissiles.size() - 1
		CurrentlySelectedMissile = AvailableMissiles[SelectedIndex]
	$Control/TextureRect/Light.Toggle(true, true)
	$Control/TextureRect/Label2.text = CurrentlySelectedMissile.ItemName

func _on_turn_off_button_pressed() -> void:
	$Control/TouchStopper.mouse_filter = MOUSE_FILTER_STOP
	if (Armed):
		_on_dissarm_drone_button_2_pressed()
	$AnimationPlayer.play("Hide")

func _on_drone_range_slider_value_changed(value: float) -> void:
	$Control/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer4/Label2.text = var_to_str(value / 2)
	#DroneDockEventH.OnDronRangeChanged(value)
