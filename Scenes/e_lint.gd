extends Control

@export var DirectionMasks : Dictionary
@export var DistanceMasks : Array[Texture2D]
@export var OnOffTextures : Array[Texture2D]

@export var Alarm : AudioStream
@export var Beep : AudioStream

var Lights : Array[Light2D] = []

var ConnectedShip : MapShip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for g in get_children():
		if g is Light2D:
			Lights.append(g)
			g.visible = false
	
	#SetDirection(67)
	#SetDistance(800)

func ToggleElint(t : bool) -> void:
	if (t):
		$TextureRect.texture = OnOffTextures[0]
		set_physics_process(true)
	else:
		$TextureRect.texture = OnOffTextures[1]
		set_physics_process(false)
		
func UpdateConnectedShip(Sh : MapShip) -> void:
	ConnectedShip = Sh
	if Sh is Drone:
		ToggleElint(false)
	else :
		ToggleElint(true)
		
var d = 0.4
func _physics_process(delta: float) -> void:
	#UpdateBasedOnMouse()
	d -= delta
	if (d > 0):
		return
	d = 0.4
	
	var Elint = ConnectedShip.GetClosestElint()
	if (Elint == Vector2.ZERO):
		for g in Lights:
			g.visible = false
		return
	else :
		SetDirection(rad_to_deg(ConnectedShip.global_position.angle_to_point(Elint)) + 180)
		SetDistance(ConnectedShip.global_position.distance_to(Elint))
	
	for g in Lights:
		g.visible = !g.visible
	if ($RangeIndicator.visible):
		$AudioStreamPlayer.play()

func UpdateBasedOnMouse() -> void:
	var mpos = get_global_mouse_position()
	var pos = $Control.global_position as Vector2
	var ang = (rad_to_deg(pos.angle_to_point(mpos))) + 180
	SetDirection(ang)
	SetDistance(pos.distance_to(mpos))

func SetDirection(dir : float):
	#print(dir)
	for g in DirectionMasks.size():
		if (abs(DirectionMasks.keys()[g] - dir) > 15):
			continue
		$DirectionLight.texture = DirectionMasks.values()[g]
		return
	
func SetDistance(dist : float):
	if (dist < 300):
		if ($RangeIndicator.texture != DistanceMasks[2]):
			$RangeIndicator.texture = DistanceMasks[2]
			Lights.append($DangerCloseLight)
			$DangerCloseLight.visible = $DirectionLight.visible
			$AudioStreamPlayer.stream = Alarm
			$AudioStreamPlayer.pitch_scale = 4
	else : if (dist < 600):
		if ( $RangeIndicator.texture != DistanceMasks[1]):
			$RangeIndicator.texture = DistanceMasks[1]
			Lights.erase($DangerCloseLight)
			$DangerCloseLight.visible = false
			#$AudioStreamPlayer.playing = false
			$AudioStreamPlayer.stream = Beep
			$AudioStreamPlayer.pitch_scale = 1
	else :
		if ( $RangeIndicator.texture != DistanceMasks[0]):
			$RangeIndicator.texture = DistanceMasks[0]
			Lights.erase($DangerCloseLight)
			$DangerCloseLight.visible = false
			$AudioStreamPlayer.stream = Beep
			$AudioStreamPlayer.pitch_scale = 1
			#$AudioStreamPlayer.playing = false