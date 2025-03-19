extends CharacterBody2D

@export var speed: float = 50.0  
@export var attack_damage: int = 10  
@export var attack_interval: float = 1.5  
@export var patrol_wait_time: float = 2.0  
@export var chase_range: float = 150.0  
@export var patrol_range: float = 300.0  
@export var max_health: int = 200  

@onready var navigation_agent = $NavigationAgent2D  
@onready var anim = $AnimationPlayer  
@onready var detection_area = $DetectionArea  
@onready var attack_area = $AttackArea  
@onready var health_bar = $HealthBar/HealthBar  # Добавляем ссылку на шкалу здоровья

var player: CharacterBody2D = null
var is_attacking: bool = false
var can_attack: bool = true  
var is_patrolling: bool = true  
var is_waiting: bool = false  
var last_direction: Vector2 = Vector2.DOWN
var patrol_target: Vector2
var current_health: int  
var is_dead: bool = false  

func _ready():
	current_health = max_health
	patrol_target = global_position
	choose_new_destination()

	health_bar.value = current_health  # Устанавливаем текущее здоровье
	health_bar.max_value = max_health  # Устанавливаем максимум
	health_bar.hide()  # Скрываем шкалу в начале

func _process(delta):
	if is_dead or is_attacking:
		return

	if player:
		chase_player()
	elif is_patrolling and not is_waiting:
		patrol()

func choose_new_destination():
	if is_waiting or is_dead:
		return

	is_waiting = true  
	velocity = Vector2.ZERO
	anim.play("idle_" + get_idle_direction())

	await get_tree().create_timer(patrol_wait_time).timeout

	var random_offset = Vector2(randi_range(-100, 100), randi_range(-100, 100))
	patrol_target = global_position + random_offset
	navigation_agent.target_position = patrol_target

	is_waiting = false  

func patrol():
	if is_dead:
		return

	if navigation_agent.is_navigation_finished():
		choose_new_destination()
		return

	move_to(navigation_agent.get_next_path_position())

func chase_player():
	if is_dead:
		return

	if player and global_position.distance_to(player.global_position) > patrol_range:
		player = null
		is_patrolling = true
		choose_new_destination()
		return

	navigation_agent.target_position = player.global_position
	move_to(navigation_agent.get_next_path_position())

	if attack_area.overlaps_body(player) and can_attack:
		attack()

func move_to(target_pos: Vector2):
	if is_attacking or is_dead:  
		velocity = Vector2.ZERO
		return

	var direction = (target_pos - global_position).normalized()

	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		anim.play("idle_" + get_idle_direction())
		return

	velocity = direction * speed
	move_and_slide()

	if direction.x > 0:
		last_direction = Vector2.RIGHT
		anim.play("walk_right")
	elif direction.x < 0:
		last_direction = Vector2.LEFT
		anim.play("walk_left")
	elif direction.y > 0:
		last_direction = Vector2.DOWN
		anim.play("walk_down")
	elif direction.y < 0:
		last_direction = Vector2.UP
		anim.play("walk_up")

func attack():
	if is_attacking or not player or is_dead:
		return
	
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO  

	var attack_anim = "attack_right" if last_direction == Vector2.RIGHT else "attack_left"
	anim.play(attack_anim)

	await get_tree().create_timer(0.3).timeout  

	if player and attack_area.overlaps_body(player) and player.has_method("take_damage"):
		player.take_damage(attack_damage)

	await get_tree().create_timer(attack_interval).timeout
	can_attack = true
	is_attacking = false

func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	health_bar.value = current_health  # Обновляем шкалу здоровья

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true  
	velocity = Vector2.ZERO  
	set_process(false)  
	anim.play("death")  

	await anim.animation_finished  
	queue_free()

func get_idle_direction():
	if last_direction == Vector2.RIGHT:
		return "right"
	elif last_direction == Vector2.LEFT:
		return "left"
	elif last_direction == Vector2.DOWN:
		return "down"
	elif last_direction == Vector2.UP:
		return "up"
	return "down"

func _on_detection_area_body_entered(body):
	if is_dead:
		return

	if body.name == "Player":
		player = body
		is_patrolling = false
		health_bar.show()  # Показываем шкалу здоровья

func _on_detection_area_body_exited(body):
	if is_dead:
		return

	if body == player:
		player = null
		is_patrolling = true
		choose_new_destination()
		health_bar.hide()  # Скрываем шкалу здоровья
