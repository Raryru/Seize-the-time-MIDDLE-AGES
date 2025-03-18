extends TextureProgressBar

@export var max_time: float = 100.0  # Максимальное время
@export var decrease_rate: float = 0.1  # Скорость уменьшения времени в секунду

var current_time: float

func _ready():
	current_time = max_time
	value = current_time  # Устанавливаем начальное значение

func _process(delta):
	current_time -= decrease_rate * delta  # Уменьшаем время
	value = current_time  # Обновляем шкалу

	if current_time <= 0:
		game_over()

func add_time(amount: float):
	current_time = min(current_time + amount, max_time)  # Добавляем время, но не больше max_time
	value = current_time  # Обновляем шкалу

func game_over():
	print("Время истекло! Игрок проиграл.")  
	get_tree().change_scene_to_file("res://Scenes/UI_Scenes/Menu/game_over.tscn")  # Переход в меню проигрыша
