extends Node

class_name SimulationManager

static var Paused : bool = false
static var SimulationSpeed : int = 1

static  var Instance : SimulationManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Instance = self
	var notif = SimulationNotification.GetInstance()
	notif.visible = false
	notif.set_physics_process(false)

static func GetInstance() -> SimulationManager:
	return Instance

static func IsPaused() -> bool:
	return Paused
	
func TogglePause(t : bool) -> void:
	var notif = SimulationNotification.GetInstance()
	notif.visible = t
	notif.set_physics_process(t)
	Paused = t
	get_tree().call_group("Ships", "TogglePause", t)
	Inventory.GetInstance().OnSimulationPaused(t)
	get_tree().call_group("Clock", "ToggleSimulation", t)

func SetSimulationSpeed(Speed : int) -> void:
	SimulationSpeed = Speed
	get_tree().call_group("Ships", "ChangeSimulationSpeed", SimulationSpeed)
	$"../VBoxContainer/Inventory".OnSimulationSpeedChanged(SimulationSpeed)
	get_tree().call_group("Clock", "SimulationSpeedChanged", SimulationSpeed)

func SpeedToggle(t : bool) -> void:
	if (t):
		SimulationSpeed = 10
	else:
		SimulationSpeed = 1
	get_tree().call_group("Ships", "ChangeSimulationSpeed", SimulationSpeed)
	$"../Inventory".OnSimulationSpeedChanged(SimulationSpeed)
	get_tree().call_group("Clock", "SimulationSpeedChanged", SimulationSpeed)
