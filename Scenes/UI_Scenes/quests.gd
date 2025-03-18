extends Node2D

@onready var button = $Button

@onready var anim := $AnimatedSprite2D

var quest_opened := false
var anim_finished := false
var pressable := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("quest"):
		_on_button_pressed()

func _on_animated_sprite_2d_animation_finished(anim_name) -> void:
	if anim_name == "opened":
		pressable = false
		await(get_tree().create_timer(1.0).timeout)
		pressable = true
		print("5 seconds")
		anim.stop()
		anim.play("default_opened")
		anim_finished = true
	else:
		pressable = false
		await(get_tree().create_timer(1.0).timeout)
		pressable = true
		print("5 seconds")
		anim.stop()
		anim.play("default_closed")
		anim_finished = true



func _on_button_pressed() -> void:
	if quest_opened == false and pressable == true:
		await anim_finished == true
		quest_opened = true
		print("Button pressed")
		anim.play("opened")
		_on_animated_sprite_2d_animation_finished("opened")
		anim_finished = false
	elif pressable == true:
		
		await anim_finished == true
		
		print("butnprs")
		anim.play("closed")
		_on_animated_sprite_2d_animation_finished("closed")
		anim_finished = false
	else:
		print("Wait")
