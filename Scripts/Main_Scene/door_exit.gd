extends Area2D

@export var target_scene_path: String = "res://Scenes/Levels/main_scene.tscn"  # Путь к улице
@onready var interaction_hint = $"../InteractionHint"

var player_inside: bool = false  

func _ready():
	interaction_hint.hide()

func _on_door_exit_body_entered(body):
	if body.name == "Player":
		player_inside = true
		interaction_hint.show()

func _on_door_exit_body_exited(body):
	if body.name == "Player":
		player_inside = false
		interaction_hint.hide()

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):  
		change_scene()

func change_scene():
	var target_scene = load(target_scene_path)
	if target_scene is PackedScene:
		get_tree().change_scene_to_packed(target_scene)
	else:
		print("Ошибка: не удалось загрузить сцену " + target_scene_path)
