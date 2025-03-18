extends Camera2D

@export var target: Node2D  # Игрок
@export var smoothing_speed: float = 5.0  # Скорость плавного движения камеры

func _physics_process(delta):
	if target:
		position = position.lerp(target.position, smoothing_speed * delta)
