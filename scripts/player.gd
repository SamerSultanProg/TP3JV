extends CharacterBody2D
class_name Player

@export var MAX_SPEED: float = 180.0
@export var ACCEL: float = 1200.0
@export var DECEL: float = 1600.0
@export var JUMP_VELOCITY: float = -400.0

var facing_right: bool = true

func _physics_process(delta: float) -> void:
	# Gravité de Godot 4 (retourne un Vector2)
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

func get_animation_player() -> Object:
	# On utilise AnimatedSprite2D dans ton projet, mais garde un fallback
	if has_node("AnimatedSprite2D"):
		return get_node("AnimatedSprite2D")
	elif has_node("AnimationPlayer"):
		return get_node("AnimationPlayer")
	return null

func get_sprite() -> AnimatedSprite2D:
	return get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func set_facing(right: bool) -> void:
	facing_right = right
	var spr := get_sprite()
	if spr:
		spr.flip_h = not right   # right=true -> flip_h=false, left -> true
