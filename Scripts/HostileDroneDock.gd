extends Node2D
class_name HostileDroneDock

var DockedDrones : Array[HostileShip]

func HasSpace() -> bool:
	return DockedDrones.size() < 6

#func GetSaveData() -> Array[DroneSaveData]:
	#var saved : Array[DroneSaveData]
	#for g in DockedDrones:
		#saved.append(g.GetSaveData())
	#return saved
	
#func LoadSaveData( Dat : Array[DroneSaveData]) -> void:
	#for g in Dat:
		#var dr = AddCaptain(g.Cpt, false)
		#dr.Cpt.GetStat("FUEL_TANK").CurrentVelue = g.Fuel
		#if (!g.Docked):
			#UndockDrone(dr)
			#dr.EnableDrone()
			#dr.global_position = g.Pos
			#dr.global_rotation = g.Rot
			#dr.CommingBack = g.CommingBack
	
func GetCaptains() -> Array[Captain]:
	var cptns : Array[Captain]
	for g in DockedDrones:
		cptns.append(g.Cpt)
	return cptns
	
func DroneDisharged(Dr : Drone):
	if (DockedDrones.has(Dr)):
		DockedDrones.erase(Dr)
	ShipData.GetInstance().RemoveCaptainStats([Dr.Cpt.GetStat("INVENTORY_CAPACITY")])
	Inventory.GetInstance().UpdateSize()
	MapPointerManager.GetInstance().RemoveShip(Dr)
	Dr.queue_free()

func AddShip(Ship : HostileShip, Notify : bool = true) -> void:
	AddShipToHierarchy(Ship)

func AddShipToHierarchy(Ship : HostileShip):
	get_parent().get_parent().add_child(Ship)
	DockShip(Ship)

func DockShip(Ship : HostileShip):
	DockedDrones.append(Ship)
	#Ship.DissableShip()
	
	var docks = $DroneSpots.get_children()
	for g in docks.size():
		if (docks[g].get_child_count() > 0):
			continue
		var dock = docks[g]
		var trans = RemoteTransform2D.new()
		trans.update_rotation = false
		dock.add_child(trans)
		trans.remote_path = Ship.get_path()
		Ship.Docked = true
		return

func UndockDrone(drone : Drone):
	DockedDrones.erase(drone)
	var docks = $DroneSpots.get_children()
	for g in docks.size():
		if (docks[g].get_child_count() > 0):
			var trans = docks[g].get_child(0) as RemoteTransform2D
			if (trans.remote_path == drone.get_path()):
				trans.free()
				drone.Docked = false
				return
