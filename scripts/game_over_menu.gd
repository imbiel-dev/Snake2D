extends CanvasLayer

#signal to restart the game
signal restart

#called when the node is added to the scene
func _ready():
	set_process(true) #enable processing

#called every frame
func _process(_delta):
	if Input.is_action_just_pressed("ui_restart"):
		_on_restart_button_pressed()

#function called when the restart button is pressed
func _on_restart_button_pressed():
	restart.emit() #emit the restart signal
