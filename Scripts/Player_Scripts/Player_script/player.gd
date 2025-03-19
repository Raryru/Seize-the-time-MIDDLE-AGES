extends CharacterBody2D 

@export var speed: float = 70.0
@export var max_health: int = 100
@export var attack_damage: int = 20
@export var attack_duration: float = 0.5
@export var attack_cooldown: float = 1.0
@export var death_duration: float = 1.0
@export var heal_amount: int = 5  # Количество восстанавливаемого здоровья за раз
@export var heal_delay: float = 10.0  # Через сколько секунд после удара начнется восстановление
@export var heal_interval: float = 3.0  # Как часто восстанавливается здоровье

var current_health: int  
var direction := Vector2.ZERO  
var last_direction := "down"  
var is_attacking := false  
var is_dead := false  
var can_attack := true  
var healing := false  # Флаг процесса восстановления здоровья
var last_damage_time := 0.0  # Время последнего получения урона

@onready var anim := $Animationsecondversion  
@onready var attack_area := $AttackArea  
@onready var player_camera := get_parent().get_node("Player_Camera")  
@onready var hp_ui := player_camera.get_node("HP")  
@onready var health_bar := hp_ui.get_node("HealthBar")  
@onready var heart_icon := hp_ui.get_node("HeartIcon")  

@onready var full_heart_texture := preload("res://Sprites/HUDandFE/HPBAR/health_full.png")  
@onready var half_heart_texture := preload("res://Sprites/HUDandFE/HPBAR/health_half.png")  
@onready var low_heart_texture := preload("res://Sprites/HUDandFE/HPBAR/health_low.png")  

func _ready():
	current_health = max_health
	health_bar.value = current_health
	health_bar.max_value = max_health
	health_bar.show()  
	heart_icon.texture = full_heart_texture  

func _physics_process(delta):
	if is_dead:
		return
	
	if not is_attacking:
		move_player()

	if Input.is_action_just_pressed("attack") and not is_attacking and can_attack:
		attack()
	
	# Проверка, можно ли начать восстановление здоровья
	if not healing and current_health < max_health and Time.get_ticks_msec() - last_damage_time > heal_delay * 1000:
		start_healing()

func move_player():
	var new_direction := Vector2.ZERO  

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
	can_attack = false  

	var attack_anim = "attack_" + last_direction
	anim.play(attack_anim)

	for body in attack_area.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):  
			body.take_damage(attack_damage)

	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true  

func take_damage(amount: int):
	if is_dead:
		return
	
	current_health -= amount
	health_bar.value = current_health  
	update_heart_texture()  
	last_damage_time = Time.get_ticks_msec()  # Запоминаем время получения урона
	healing = false  # Останавливаем процесс восстановления

	print("[PLAYER] Получил урон:", amount, "Осталось здоровья:", current_health)

	if current_health <= 0:
		die()

func update_heart_texture():
	if current_health <= max_health * 0.25:
		heart_icon.texture = low_heart_texture  
	elif current_health <= max_health * 0.5:
		heart_icon.texture = half_heart_texture  
	else:
		heart_icon.texture = full_heart_texture  

func start_healing():
	healing = true
	while current_health < max_health:
		await get_tree().create_timer(heal_interval).timeout
		if Time.get_ticks_msec() - last_damage_time < heal_delay * 1000:  # Проверяем, не получал ли игрок урон во время восстановления
			healing = false
			break
		current_health = min(current_health + heal_amount, max_health)
		health_bar.value = current_health
		update_heart_texture()
		print("[PLAYER] Восстановление здоровья:", current_health)
		if current_health == max_health:
			healing = false

func die():
	if is_dead:
		return

	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO  
	anim.play("death")

	print("[PLAYER] Игрок погиб.")
	await get_tree().create_timer(death_duration).timeout
	queue_free()
