extends Control

class_name ShipMarker

@export_group("Nodes")
@export var Direction : Label
@export var ShipCallsign : Label
@export var ShipNameLabel : Label
@export var ShipSpeedLabel : Label
@export var TimeSeenLabel : Label
@export var ThreatLabel : Label
@export var FuelLabel : Label
@export var HullLabel : Label
@export var DetailPanel : Control
@export var ShipIcon : TextureRect
@export_group("Resources")
#@export var EnemyLocatedNotifScene : PackedScene

@export var EnemyLocatedSound : AudioStream

#@export var DroneReturnNotif : PackedScene

@export var ResuplyNotificationScene : PackedScene

@export var NotificationScene : PackedScene

@export var Icons : Dictionary

var TimeLastSeen : float

#var DetailInitialPos : Vector2

var Showspeed : bool = false

var ElintNotif : ShipMarkerNotif
var LandingNotif : ShipMarkerNotif

var CurrentZoom : float

signal ShipDeparted

func _ready() -> void:
	#DetailInitialPos = $Control/PanelContainer/VBoxContainer.position
	DetailPanel.visible = false
	$Line2D.visible = false
	TimeSeenLabel.visible = false
	#$Control/PanelContainer/VBoxContainer/Threat.visible = false
	FuelLabel.visible = false
	HullLabel.visible = false
	
	#set_physics_process(false)
func PlayHostileShipNotif(text : String) -> void:
	var notif = NotificationScene.instantiate() as ShipMarkerNotif
	notif.SetText(text)
	var sound = DeletableSoundGlobal.new()
	sound.stream = EnemyLocatedSound
	sound.volume_db = -10
	sound.bus = "UI"
	sound.autoplay = true
	add_child(sound)
	add_child(notif)
	
func OnShipDeparted() -> void:
	ShipDeparted.emit()
	ToggleShowRefuel("Refueling", false, 0)
	ToggleShowRefuel("Repairing", false, 0)
	ToggleShowRefuel("Upgrading", false, 0)

func UpdateTrajectory(Dir : float) -> void:
	Direction.rotation = Dir

func DroneReturning() -> void:
	var notif = NotificationScene.instantiate() as ShipMarkerNotif
	notif.SetText("Drone Returning To Base")
	add_child(notif)

func SetType(T : String) -> void:
	ShipIcon.texture = Icons[T]
	
func ToggleShowRefuel(Stats : String, t : bool, timel : float = 0):
	var notif : ResuplyNotification
	for g in get_children():
		if g is ResuplyNotification:
			g.ToggleStat(Stats, t, timel)
			return
	if (t):
		notif = ResuplyNotificationScene.instantiate() as ResuplyNotification
		notif.ToggleStat(Stats, t, timel)
		connect("ShipDeparted", notif.OnShipDeparted)
		add_child(notif)

func ToggleShowElint( t : bool, ElingLevel : int, Direction : String):
	if ElintNotif != null:
		if (t):
			ElintNotif.SetText("ELINT : Lvl {0} \nDiretion : {1}".format([var_to_str(ElingLevel), Direction]))
			return
		else :
			ElintNotif.queue_free()
			ElintNotif = null
			return
	if (t):
		ElintNotif = NotificationScene.instantiate() as ShipMarkerNotif
		ElintNotif.SetText("ELINT : {0} \nDiretion : {1}".format([var_to_str(ElingLevel), Direction]))
		ElintNotif.Blink = true
		ElintNotif.Fast = true
		#connect("ShipDeparted", notif.OnShipDeparted)
		add_child(ElintNotif)

func OnLandingStarted():
	LandingNotif = NotificationScene.instantiate() as ShipMarkerNotif
	#LandingNotif.SetText("ELINT : " + var_to_str(ElingLevel))
	LandingNotif.Blink = false
	#connect("ShipDeparted", notif.OnShipDeparted)
	add_child(LandingNotif)
func OnLandingEnded(_Ship : MapShip):
	LandingNotif.queue_free()
	LandingNotif = null

func ToggleShipDetails(T : bool):
	DetailPanel.visible = T
	$Line2D.visible = T
	#Direction.visible = T
	#set_physics_process(T)
func ToggleFriendlyShipDetails(T : bool):
	FuelLabel.visible = T
	HullLabel.visible = T
func OnStatLow(StatName : String) -> void:
	var notif = NotificationScene.instantiate() as ShipMarkerNotif
	notif.SetText(StatName + " bellow 20%")
	#notif.SetStatData(StatName)
	#notif.rotation = -rotation
	#notif.EntityToFollow = self
	add_child(notif)
	
func SetMarkerDetails(ShipName : String, ShipCasllSign : String, ShipSpeed : float):
	ShipNameLabel.text = ShipName
	ShipSpeedLabel.text = "Speed " + var_to_str(ShipSpeed * 360).replace(".0", "") + "km/h"
	ShipCallsign.text = ShipCasllSign
	
func UpdateCameraZoom(NewZoom : float) -> void:
	DetailPanel.scale = Vector2(1,1) / NewZoom
	ShipIcon.scale = (Vector2(1,1) / NewZoom) * 0.5
	#$ShipSymbol.scale = Vector2(1,1) / camera.zoom
	UpdateLine(NewZoom)
	$Line2D.width =  2 / NewZoom
	CurrentZoom = NewZoom

func UpdateLine(Zoom : float)-> void:
	var locp = get_closest_point_on_rect($Control/PanelContainer/VBoxContainer.get_global_rect(), DetailPanel.global_position)
	$Line2D.set_point_position(1, locp - $Line2D.global_position)
	$Line2D.set_point_position(0, global_position.direction_to(locp) * 30 / Zoom)

func UpdateSpeed(Spd : float):
	Direction.visible = Spd > 0
	var spd = roundi(Spd * 360)
	ShipSpeedLabel.text = "Spd " + var_to_str(spd).replace(".0", "") + "km/h"
func UpdateAltitude(Alt : float):
	LandingNotif.SetText("ALT : " + var_to_str(Alt))
func UpdateDroneFuel(amm : float, maxamm : float):
	FuelLabel.text = "F: {0} / {1}".format([amm, maxamm])
func UpdateDroneHull(amm : float, maxamm : float):
	HullLabel.text = "H: {0} / {1}".format([amm, maxamm])

func ToggleTimeLastSeend(T : bool):
	if (!T):
		TimeLastSeen = 0
	else: if (TimeLastSeen == 0):
		TimeLastSeen = Clock.GetInstance().GetTimeInHours()
	TimeSeenLabel.visible = T

func UpdateTime():
	var timepast = Clock.GetInstance().GetHoursSince(TimeLastSeen)
	TimeSeenLabel.text = "Last Seen " + var_to_str(snappedf((timepast) , 0.01)) + "h ago"

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$Control/PanelContainer/VBoxContainer.add_to_group("MapInfo")
	ShipIcon.add_to_group("UnmovableMapInfo")
	add_to_group("ZoomAffected")
	UpdateCameraZoom(ShipCamera.GetInstance().zoom.x)
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$Control/PanelContainer/VBoxContainer.remove_from_group("MapInfo")
	ShipIcon.remove_from_group("UnmovableMapInfo")
	remove_from_group("ZoomAffected")
func UpdateSignRotation() -> void:
	DetailPanel.rotation += 0.01
	$Control/PanelContainer.pivot_offset = $Control/PanelContainer.size / 2
	$Control/PanelContainer.rotation -= 0.01
	var locp = get_closest_point_on_rect($Control/PanelContainer/VBoxContainer.get_global_rect(), DetailPanel.global_position)
	$Line2D.set_point_position(1, locp - $Line2D.global_position)
	$Line2D.set_point_position(0, global_position.direction_to(locp) * 30 / CurrentZoom)

	
func get_closest_point_on_rect(rect: Rect2, point: Vector2) -> Vector2:
	var closest_x = clamp(point.x, rect.position.x, rect.position.x + rect.size.x)
	var closest_y = clamp(point.y, rect.position.y, rect.position.y + rect.size.y)
	return Vector2(closest_x, closest_y)
