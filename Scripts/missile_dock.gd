extends Node2D

class_name MissileDock

@export var MissileDockEventH : MissileDockEventHandler

var Missiles : Array[MissileItem]

func _ready() -> void:
	$MissileLine.visible = false
	MissileDockEventH.connect("OnMissileDirectionChanged", MissileAimDirChanged)
	MissileDockEventH.connect("OnMissileArmed", MissileArmed)
	MissileDockEventH.connect("OnMissileDissarmed", MissileDissarmed)
	MissileDockEventH.connect("MissileLaunched", LaunchMissile)
	MissileDockEventH.connect("MissileAdded", AddMissile)
	MissileDockEventH.connect("MissileRemoved", MissileRemoved)
	#for g in 2:
		#var drone = DroneScene.instantiate()
		#call_deferred("AddDroneToHierarchy",drone)

func ClearAllMissiles() -> void:
	for g in Missiles:
		MissileRemoved(g)
		
#func GetCaptains() -> Array[Captain]:
	#var cptns : Array[Captain]
	#for g in DockedDrones:
		#cptns.append(g.Cpt)
	#for g in FlyingDrones:
		#cptns.append(g.Cpt)
	#return cptns
func MissileRemoved(Mis : MissileItem):
	if (Missiles.has(Mis)):
		Missiles.erase(Mis)
func AddMissile(Mis : MissileItem):
	Missiles.append(Mis)

func MissileArmed(Mis : MissileItem) -> void:
	$MissileLine.set_point_position(1, Vector2(Mis.Distance, 0))
	$MissileLine.visible = true

func MissileDissarmed() -> void:
	$MissileLine.visible = false

func MissileAimDirChanged(NewDir : float) -> void:
	$MissileLine.rotation += NewDir
	
func LaunchMissile(Mis : MissileItem) -> void:
	var missile = Mis.MissileScene.instantiate() as Missile
	missile.MissileName = Mis.MissileName
	missile.Speed = Mis.Speed
	missile.Distance = Mis.Distance
	missile.global_rotation = $MissileLine.global_rotation
	missile.global_position = global_position
	get_parent().get_parent().add_child(missile)
	#MissileDockEventH.MissileLaunched(Mis)