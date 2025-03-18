extends Area2D

@export var room_scene: String = "res://Scenes/Levels/house_interior.tscn"  # Путь к сцене комнаты

@onready var interaction_hint = $"../Player_Camera/InteractionHint"

var player_inside = false
var player = null  # Храним ссылку на игрока

func _ready():
	interaction_hint.hide()

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact") and player:
		change_scene_with_spawn()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player_inside = true
		player = body
		interaction_hint.show()

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player_inside = false
		player = null
		interaction_hint.hide()

func change_scene_with_spawn():
	if room_scene and player:
		# Получаем дерево сцен
		var scene_tree = get_tree()
		if scene_tree:
			# Меняем сцену
			scene_tree.change_scene_to_file(room_scene)

			# Ждём 1 кадр, чтобы убедиться, что новая сцена загружена
			await scene_tree.process_frame  

			# Получаем текущую сцену (уже загруженную)
			var new_scene = scene_tree.current_scene

			# Ищем точку появления игрока
			var spawn_point = new_scene.get_node_or_null("SpawnPoint")
			if spawn_point:
				player.global_position = spawn_point.global_position  # Перемещаем игрока
		else:
			print("Ошибка: сцена не может быть изменена, так как scene_tree = null!")
	else:
		print("Ошибка: сцена не загружена или игрок не найден!")
