extends Happening_Option
class_name Drone_Happening_Option

var DroneScene : String = "res://Scenes/drone.tscn"
@export var Cpt : Captain

#func _init() -> void:
	#Dron = DroneScene.instantiate()

func OptionResault() -> String:
	return "A new ship has joined your fleet."
func OptionOutCome(Instigator : MapShip) -> void:
	Instigator.GetDroneDock().AddRecruit(Cpt)
