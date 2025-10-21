extends CharacterBody2D

# --- Gameplay ---
const SPEED := 300.0
const JUMP_VELOCITY := -400.0

# --- FSM ---
enum State { IDLE, RUN, JUMP, FALL, ATTACK }
var state: State = State.IDLE
var can_control := true

# --- Nodes (safe lookups) ---
@onready var sprite: AnimatedSprite2D = (
	get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
)

@onready var attack_timer: Timer = (
	get_node_or_null("AttackTimer") as Timer
	if get_node_or_null("AttackTimer") != null
	else get_node_or_null("AnimatedSprite2D/AttackTimer") as Timer
)

func _ready() -> void:
	if attack_timer != null:
		attack_timer.one_shot = true
		if not attack_timer.timeout.is_connected(_on_attack_finished):
			attack_timer.timeout.connect(_on_attack_finished)
	else:
		push_warning("AttackTimer introuvable (met-le enfant du joueur ou sous AnimatedSprite2D).")
	if sprite == null:
		push_warning("AnimatedSprite2D introuvable (nom exact requis).")

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	if can_control:
		_handle_input()
	_update_state()
	_play_animation()
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta   # Godot 4 returns a Vector2
	elif velocity.y > 0.0:
		velocity.y = 0.0

func _handle_input() -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	if sprite != null and dir != 0.0:
		sprite.flip_h = dir < 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor() and state != State.ATTACK:
		velocity.y = JUMP_VELOCITY
		state = State.JUMP

	if Input.is_action_just_pressed("attack") and state != State.ATTACK:
		_start_attack()

func _start_attack() -> void:
	state = State.ATTACK
	can_control = false
	velocity.x = 0.0

	if sprite != null:
		sprite.play("attack")

	# ---- FIX: compute duration from frame count / FPS (no get_animation_length in Godot 4) ----
	var dur := 0.25
	if sprite != null and sprite.sprite_frames and sprite.sprite_frames.has_animation("attack"):
		var frames := sprite.sprite_frames
		var fc := frames.get_frame_count("attack")          # number of frames
		var spd := 12.0                                     # fallback FPS
		# Godot 4 SpriteFrames has per-animation speed:
		if frames.has_method("get_animation_speed"):
			spd = frames.get_animation_speed("attack")
		# duration = frames / fps (guard against zero):
		if fc > 0 and spd > 0.0:
			dur = max(0.1, float(fc) / spd)

	if attack_timer != null:
		attack_timer.start(dur)
	else:
		# fallback if no timer in the scene
		await get_tree().create_timer(dur).timeout
		_on_attack_finished()

func _on_attack_finished() -> void:
	can_control = true

func _update_state() -> void:
	if state == State.ATTACK:
		return
	if not is_on_floor():
		state = State.JUMP if velocity.y < 0.0 else State.FALL
	else:
		state = State.RUN if abs(velocity.x) > 5.0 else State.IDLE

func _play_animation() -> void:
	if sprite == null:
		return
	match state:
		State.IDLE:
			sprite.play("idle")
		State.RUN:
			sprite.play("run")
		State.JUMP:
			sprite.play("jump")
		State.FALL:
			sprite.play("fall")
		State.ATTACK:
			# already playing
			pass
