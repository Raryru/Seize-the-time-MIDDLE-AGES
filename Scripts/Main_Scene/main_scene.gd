extends Node2D

@onready var game_menu = $Player_Camera/game_menu

func _ready() -> void:
	game_menu.hide()

func _on_esc_pressed() -> void:
	get_tree().paused = !get_tree().paused
	game_menu.show()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://Scenes/UI_Scenes/Menu/main_menu.tscn")


func _on_return_menu_pressed() -> void:
	get_tree().paused = !get_tree().paused
	game_menu.hide()
