extends Control

class_name PopUpManager
@export var CustomPop : PackedScene
@export var CustomConfirm : PackedScene
static var Instance : PopUpManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Instance = self
	pass # Replace with function body.

static func GetInstance() -> PopUpManager:
	return Instance
	
func DoPopUp(Text : String):
	var dig = CustomPop.instantiate() as AcceptDialog
	add_child(dig)
	dig.dialog_text = Text
	dig.popup_centered()
func DoConfirm(Text : String, ConfirmText : String, Method : Callable):
	var dig = CustomConfirm.instantiate() as ConfirmationDialog
	dig.connect("confirmed", Method)
	add_child(dig)
	dig.dialog_text = Text
	dig.ok_button_text = ConfirmText
	dig.popup_centered()