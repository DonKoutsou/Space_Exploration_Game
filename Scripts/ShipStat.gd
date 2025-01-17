extends Resource
class_name ShipStat

@export var StatName : String
@export var StatMax : float
@export var StatBase : float
@export var StatShipBuff : float = 0
@export var StatItemBuff : float = 0
@export var CurrentVelue : float = 0
@export var AllowAutoRefil : bool = false

func GetBaseStat()-> float:
	return StatBase
func GetShipBuff()-> float:
	return StatShipBuff
func GetItemBuff()-> float:
	return StatItemBuff
func GetStat()-> float:
	return StatBase + StatShipBuff + StatItemBuff
func GetCurrentValue()-> float:
	return CurrentVelue
func RefilCurrentVelue(RefAmmount : float) -> void:
	CurrentVelue = clamp(CurrentVelue + RefAmmount, 0, GetStat())
func ConsumeResource(Amm : float) -> void:
	CurrentVelue -= Amm
func SetItemBuff(Amm : float) -> void:
	StatItemBuff += Amm
