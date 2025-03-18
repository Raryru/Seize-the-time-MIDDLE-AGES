extends Node

var current_scene = null
var stored_scenes = {}  # Словарь для хранения сцен

func switch_scene(new_scene_path: String, player_position: Vector2 = Vector2.ZERO):
	var root = get_tree().current_scene.get_parent()

	# Сохранение текущей сцены
	if current_scene:
		stored_scenes[current_scene.scene_file_path] = current_scene
		current_scene.reparent(self)  # Убираем сцену, но не удаляем

	# Если сцена уже загружена – возвращаем её из памяти
	if stored_scenes.has(new_scene_path):
		current_scene = stored_scenes[new_scene_path]
		current_scene.reparent(root)
	else:
		# Если сцена новая – загружаем и добавляем
		current_scene = load(new_scene_path).instantiate()
		root.add_child(current_scene)

	# Перемещаем игрока в нужное место
	var player = current_scene.get_node("Player")
	player.global_position = player_position

	# Устанавливаем новую сцену как активную
	get_tree().current_scene = current_scene
