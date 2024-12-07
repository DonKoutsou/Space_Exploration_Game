extends Control

class_name LowLeftNotif

@export var Rotate : bool = false

var ShowingStats : Dictionary

var EntityToFollow : Node2D
var camera : Camera2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = ShipCamera.GetInstance()
	$AnimationPlayer.play("ShowStat")
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass
func ToggleStat(Stat: String, t : bool, timel : float = 0):
	if (t):
		ShowingStats[Stat] = timel
	else :
		ShowingStats.erase(Stat)
	
	if (ShowingStats.size() == 0):
		queue_free()
		return
	
	var statstring : String
	for g in ShowingStats:
		statstring += g + " " + var_to_str(ShowingStats[g]).replace(".0", "") + "\n" 
	$Label.text = statstring
func OnShipDeparted():
	queue_free()

func _physics_process(_delta: float) -> void:
	rotation = -get_parent().get_parent().rotation
	scale = Vector2(-1,1) / camera.zoom
