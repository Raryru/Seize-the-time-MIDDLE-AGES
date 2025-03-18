extends CharacterBody2D

@export var speed: float = 70.0  # Скорость движения
@export var attack_duration: float = 0.5  # Длительность атаки
@export var death_duration: float = 1.0  # Длительность анимации смерти

var direction := Vector2.ZERO  # Вектор направления
var last_direction := "down"   # Последнее направление движения (по умолчанию вниз)
var is_attacking := false  # Флаг атаки
var is_dead := false  # Флаг смерти

@onready var anim := $Animationsecondversion  # Ссылка на AnimationPlayer

func _physics_process(delta):
	if is_dead:
		return
	
	if not is_attacking:
		move_player()

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	if Input.is_action_just_pressed("die") and not is_dead:  # Тестовая кнопка смерти
		die()

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
	var attack_anim = "attack_" + last_direction
	anim.play(attack_anim)
	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false

func die():
	is_dead = true
	anim.play("death")
	await get_tree().create_timer(death_duration).timeout
	queue_free()  # Удаление персонажа после смерти
