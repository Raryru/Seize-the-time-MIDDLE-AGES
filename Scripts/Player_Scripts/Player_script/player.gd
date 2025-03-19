extends CharacterBody2D

@export var speed: float = 70.0  # Скорость движения
@export var max_health: int = 100  # Максимальное здоровье
@export var attack_damage: int = 20  # Урон атаки
@export var attack_duration: float = 0.5  # Длительность атаки
@export var attack_cooldown: float = 1.0  # Кулдаун между атаками
@export var death_duration: float = 1.0  # Длительность анимации смерти

var current_health: int  # Текущее здоровье
var direction := Vector2.ZERO  # Вектор направления
var last_direction := "down"  # Последнее направление движения
var is_attacking := false  # Флаг атаки
var is_dead := false  # Флаг смерти
var can_attack := true  # Флаг возможности атаки

@onready var anim := $Animationsecondversion  # Ссылка на AnimationPlayer
@onready var attack_area := $AttackArea  # Ссылка на зону атаки

func _ready():
	current_health = max_health  # Устанавливаем полное здоровье при старте

func _physics_process(delta):
	if is_dead:
		return
	
	if not is_attacking:
		move_player()

	if Input.is_action_just_pressed("attack") and not is_attacking and can_attack:
		attack()

func move_player():
	var new_direction := Vector2.ZERO  # Временный вектор направления
	
	if Input.is_action_pressed("move_up"):
		new_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		new_direction.y += 1
	if Input.is_action_pressed("move_left"):
		new_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		new_direction.x += 1

	if new_direction != Vector2.ZERO:
		direction = new_direction.normalized()
		velocity = direction * speed
		update_last_direction(new_direction)
		play_animation()
	else:
		velocity = Vector2.ZERO
		play_idle_animation()

	move_and_slide()

func update_last_direction(new_direction: Vector2):
	if new_direction.x > 0:
		last_direction = "right"
	elif new_direction.x < 0:
		last_direction = "left"
	elif new_direction.y > 0:
		last_direction = "down"
	elif new_direction.y < 0:
		last_direction = "up"

func play_animation():
	var anim_name = "walk_" + last_direction
	if anim.current_animation != anim_name:
		anim.play(anim_name)

func play_idle_animation():
	var idle_anim = "idle_" + last_direction
	if anim.current_animation != idle_anim:
		anim.play(idle_anim)

func attack():
	is_attacking = true
	can_attack = false  # Запрещаем атаку на время кулдауна

	var attack_anim = "attack_" + last_direction
	anim.play(attack_anim)

	# Наносим урон врагам в зоне атаки
	for body in attack_area.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):  # Проверяем, что не атакуем себя
			body.take_damage(attack_damage)

	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false

	# Запускаем кулдаун атаки
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true  # Разрешаем атаковать снова

func take_damage(amount: int):
	if is_dead:
		return
	
	current_health -= amount
	print("[PLAYER] Получил урон:", amount, "Осталось здоровья:", current_health)

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO  # Останавливаем игрока
	anim.play("death")

	print("[PLAYER] Игрок погиб.")
	await get_tree().create_timer(death_duration).timeout
	queue_free()  # Удаление персонажа после смерти
