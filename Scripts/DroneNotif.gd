extends Control

class_name DroneNotif
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Show")
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()

func SetNotifText(Stat : String) -> void:
	$Label.text = Stat