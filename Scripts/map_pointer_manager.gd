extends Node2D

class_name MapPointerManager

@export var MarkerScene : PackedScene
@export var MapSpotMarkerScene : PackedScene
@export var FriendlyColor : Color
@export var EnemyColor : Color
@export var EnemyDebug : bool = false
#@export var SpotColor : Color
var Ships : Array[Node2D] = []
var _ShipMarkers : Array[ShipMarker] = []
var Spots : Array[Node2D] = []
var _SpotMarkers : Array[SpotMarker] = []
static var Instance : MapPointerManager

func _enter_tree() -> void:
	Instance = self
static func GetInstance() -> MapPointerManager:
	return Instance

func _draw() -> void:
	pass

func DrawLines() -> void:
	pass

func AddShip(Ship : Node2D, Friend : bool) -> void:
	if (Ships.has(Ship)):
		if (Ship is HostileShip):
			_ShipMarkers[Ships.find(Ship)].PlayHostileShipNotif()
		return
	Ships.append(Ship)
	var marker = MarkerScene.instantiate() as ShipMarker
	
	add_child(marker)
	
	if (Friend):
		marker.modulate = FriendlyColor
	else:
		marker.modulate = EnemyColor

	if (Ship is HostileShip):
		if (EnemyDebug):
			#HOSTILE_SHIP_DEBUG
			marker.ToggleFriendlyShipDetails(true)
			#////
		marker.ToggleShipDetails(true)
		marker.SetMarkerDetails(Ship.ShipName, Ship.Cpt.ShipCallsign ,Ship.GetShipSpeed())
		marker.PlayHostileShipNotif()
		marker.SetType("Ship")
	else : if (Ship is MapShip):
		Ship.connect("ShipDockActions", marker.ToggleShowRefuel)
		Ship.connect("ShipDeparted", marker.OnShipDeparted)
		if (Ship is Drone):
			Ship.connect("DroneReturning", marker.DroneReturning)
		Ship.connect("Elint", marker.ToggleShowElint)
		Ship.connect("LandingStarted", marker.OnLandingStarted)
		Ship.connect("LandingCanceled", marker.OnLandingEnded)
		Ship.connect("LandingEnded", marker.OnLandingEnded)
		Ship.connect("TakeoffStarted", marker.OnLandingStarted)
		Ship.connect("TakeoffEnded", marker.OnLandingEnded)
		marker.call_deferred("ToggleShipDetails", true)
		marker.call_deferred("ToggleFriendlyShipDetails", true)
		marker.SetMarkerDetails(Ship.Cpt.CaptainName, "F",Ship.GetShipSpeed())
		marker.SetType("Ship")
	else : if (Ship is Missile):
		marker.ToggleShipDetails(true)
		marker.SetMarkerDetails(Ship.MissileName, "M",Ship.GetSpeed())
		marker.SetType("Missile")
	_ShipMarkers.append(marker)
	
func AddSpot(Spot : MapSpot, PlayAnim : bool) -> void:
	if (Spots.has(Spot)):
		return
	Spots.append(Spot)
	var marker = MapSpotMarkerScene.instantiate() as SpotMarker
	
	add_child(marker)
	
	#marker.modulate = SpotColor
	
	#marker.ToggleShipDetails(true)
	marker.SetMarkerDetails(Spot, PlayAnim)
	
	#Spot.connect("SpotAnalazyed", marker.OnSpotAnalyzed)
	
	_SpotMarkers.append(marker)
	
	marker.global_position = Spot.global_position
	
func RemoveShip(Ship : Node2D) -> void:
	if (!Ships.has(Ship)):
		return
	var index = Ships.find(Ship)
	_ShipMarkers[index].queue_free()
	_ShipMarkers.remove_at(index)
	Ships.remove_at(index)

func FixLabelClipping() -> void:
	var Mapinfos = get_tree().get_nodes_in_group("MapInfo")
	var AllMapInfos = get_tree().get_nodes_in_group("UnmovableMapInfo")
	AllMapInfos.append_array(Mapinfos)
	for g in Mapinfos:
		var control1 = g as Control
		if (!control1.is_visible_in_tree()):
			continue
		var r1 = control1.get_global_rect()
		for z in AllMapInfos:
			if (g == z):
				continue
			var control2 = z as Control
			if (!control2.is_visible_in_tree()):
				continue
			var r2 = control2.get_global_rect()
			var tries = 0
			while (r1.intersects(r2)):
				control1.owner.UpdateSignRotation()
				tries += 1
				if (tries > 10):
					return

var d = 0.1
var Circles : Array[PackedVector2Array] = []
func _physics_process(delta: float) -> void:
	FixLabelClipping()
	$CircleDrawer.UpdateCircles(Circles)
	d -= delta
	if (d > 0):
		return
	d = 0.1
	Circles.clear()
	for g in _ShipMarkers.size():
		var ship = Ships[g]
		var Marker = _ShipMarkers[g]
		
		if (ship is HostileShip):
			Marker.ToggleShipDetails(!ship.Docked)
			if (EnemyDebug):
				Marker.global_position = ship.global_position
				Marker.UpdateSpeed(ship.GetShipSpeed())

				Marker.ToggleTimeLastSeend(false)
				Marker.UpdateDroneHull(ship.Cpt.GetStat("HULL").CurrentVelue, ship.Cpt.GetStat("HULL").GetStat())
				Marker.UpdateDroneFuel(roundi(ship.Cpt.GetStat("FUEL_TANK").CurrentVelue), ship.Cpt.GetStatValue("FUEL_TANK"))
				Marker.UpdateTrajectory(ship.global_rotation)
			else:
				if (ship.VisibleBy.size() > 0):
					Marker.global_position = ship.global_position
					Marker.UpdateSpeed(ship.GetShipSpeed())
					
					Marker.ToggleTimeLastSeend(false)
					Marker.UpdateTrajectory(ship.global_rotation)
				else :
					###Marker.ToggleThreat(false)
					Marker.ToggleTimeLastSeend(true)
					Marker.UpdateTime()
		else:
			if (ship is MapShip):
				Marker.UpdateSpeed(ship.GetShipSpeed())
				Marker.ToggleShipDetails(!ship.Docked)
				if (ship.GetDroneDock().DockedDrones.size() > 0):
					var fuel = ship.Cpt.GetStat("FUEL_TANK").CurrentVelue
					var MaxFuel = ship.Cpt.GetStatFinalValue("FUEL_TANK")
					for z in ship.GetDroneDock().DockedDrones:
						fuel += z.Cpt.GetStat("FUEL_TANK").CurrentVelue
						MaxFuel += z.Cpt.GetStatFinalValue("FUEL_TANK")
					Marker.UpdateDroneFuel(roundi(fuel), MaxFuel)
				else:
					Marker.UpdateDroneFuel(roundi(ship.Cpt.GetStat("FUEL_TANK").CurrentVelue), ship.Cpt.GetStatFinalValue("FUEL_TANK"))
				Marker.UpdateDroneHull(roundi(ship.Cpt.GetStat("HULL").CurrentVelue), ship.Cpt.GetStat("HULL").GetStat())
				Marker.UpdateTrajectory(ship.global_rotation)
				if (ship.RadarWorking):
					Circles.append(PackedVector2Array([ship.global_position, Vector2(ship.Cpt.GetStatFinalValue("VIZ_RANGE"), 0)]))
				if (ship.Landing or ship.TakingOff):
					Marker.UpdateAltitude(ship.Altitude)
				#Marker.global_position = ship.global_position
			#if (ship is PlayerShip):
				#Marker.UpdateSpeed(ship.GetShipSpeed())
				#if (ship.GetDroneDock().DockedDrones.size() > 0):
					#var fuel = 0.0
					#var MaxFuel = 0.0
					#for z in ship.GetDroneDock().DockedDrones:
						#fuel += z.Cpt.GetStat("FUEL_TANK").CurrentVelue
						#MaxFuel += z.Cpt.GetStatValue("FUEL_TANK")
					#Marker.UpdateFuel(roundi(fuel), MaxFuel)
				#else:
					#Marker.UpdateFuel()
				#Marker.UpdateHull()
				#Marker.UpdateTrajectory(ship.global_rotation)
				#if (ship.RadarWorking):
					#Circles.append(PackedVector2Array([ship.global_position, Vector2(ShipData.GetInstance().GetStat("VIZ_RANGE").GetStat(), 0)]))
				#if (ship.Landing or ship.TakingOff):
					#Marker.UpdateAltitude(ship.Altitude)
				
				#Marker.global_position = ship.global_position
				#Marker.UpdateSpeed(ship.GetSpeed())
			else : if (ship is Missile):
				Marker.UpdateTrajectory(ship.global_rotation)
			Marker.global_position = ship.global_position
		
	
	
		
