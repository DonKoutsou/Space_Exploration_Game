extends PanelContainer

class_name HappeningInstance

var Hp : Happening

func _ready() -> void:
	set_physics_process(false)
	$VBoxContainer/ProgressBar.visible = false
	#PresentHappening(load("res://Resources/Happenings/TestHappening.tres"))

func PresentHappening(Hap : Happening):
	Hp = Hap
	$VBoxContainer/Label.text = Hap.HappeningName
	$VBoxContainer/Label2.text = Hap.HappeningText
	
	var OptionAmm = Hap.GetOptionsCount()
	for g in $VBoxContainer/HBoxContainer.get_child_count():
		var but = $VBoxContainer/HBoxContainer.get_child(g) as Button
		if (g >= OptionAmm):
			but.visible = false
			continue
		but.text = Hap.Options[g].OptionName
		if (Hap.Options[g] is Drone_Happening_Option):
			var Dronehap = Hap.Options[g] as Drone_Happening_Option
			but.icon = Dronehap.Cpt.CaptainPortrait

func _on_option_1_pressed() -> void:
	$VBoxContainer/Label2.text = Hp.Options[0].OptionResault()
	OnActionSelected()

func _on_option_2_pressed() -> void:
	$VBoxContainer/Label2.text = Hp.Options[1].OptionResault()
	OnActionSelected()
func _on_option_3_pressed() -> void:
	$VBoxContainer/Label2.text = Hp.Options[2].OptionResault()
	OnActionSelected()
func _on_option_4_pressed() -> void:
	$VBoxContainer/Label2.text = Hp.Options[3].OptionResault()
	OnActionSelected()
func OnActionSelected():
	$VBoxContainer/ProgressBar.visible = true
	$VBoxContainer/HBoxContainer.visible = false
	$Timer.start()
	set_physics_process(true)
	
func _physics_process(_delta: float) -> void:
	$VBoxContainer/ProgressBar.value = $Timer.time_left


func _on_timer_timeout() -> void:
	queue_free()