extends CharacterBody2D

@export var speed: float = 50.0
@export var chase_speed: float = 80.0
@export var attack_range: float = 20.0
@export var detection_range: float = 100.0
@export var patrol_radius: float = 150.0
@export var attack_cooldown: float = 1.5
@export var max_health: int = 3

var player: Node2D = null
var home_position: Vector2
var current_health: int
var attack_timer: float = 0.0
var is_attacking: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

func _ready():
	home_position = global_position
	current_health = max_health

func _process(delta):
	attack_timer -= delta

func _physics_process(delta):
	if player and player.global_position.distance_to(global_position) <= detection_range:
		chase_player(delta)
	else:
		patrol(delta)

func chase_player(delta):
	var direction = (player.global_position - global_position).normalized()
	move_and_animate(direction, chase_speed)
	
	# Атака
	if global_position.distance_to(player.global_position) <= attack_range and attack_timer <= 0:
		attack_player()

func patrol(delta):
	if global_position.distance_to(home_position) > patrol_radius:
		var direction = (home_position - global_position).normalized()
		move_and_animate(direction, speed)
	else:
		anim.play("idle_down")  # Простой, если в зоне патрулирования

func move_and_animate(direction: Vector2, speed: float):
	if is_attacking:
		return  # Не двигаться во время атаки
	
	velocity = direction * speed
	move_and_slide()

	# Выбор анимации
	if direction.x > 0:
		anim.play("walk_right")
	elif direction.x < 0:
		anim.play("walk_left")
	elif direction.y > 0:
		anim.play("walk_down")
	elif direction.y < 0:
		anim.play("walk_up")

func attack_player():
	is_attacking = true
	attack_timer = attack_cooldown
	velocity = Vector2.ZERO  # Остановиться на время атаки
	
	var attack_direction = (player.global_position - global_position).normalized()
	
	if attack_direction.x >= 0:
		anim.play("attack_right")
	else:
		anim.play("attack_left")

	attack_area.monitoring = true  # Включаем область атаки
	await get_tree().create_timer(0.3).timeout  # Время на атаку
	attack_area.monitoring = false  # Выключаем область атаки
	is_attacking = false

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		body.take_damage(1)  # Вызываем у игрока метод получения урона

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()
