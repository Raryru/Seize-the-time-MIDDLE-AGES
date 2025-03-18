extends Node2D

@onready var label = $Label
var degr = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_label()

func move_label():
	label.position.y -= 2 * degr


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI_Scenes/Menu/main_menu.tscn")
