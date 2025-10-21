class_name PlayerRun
extends BaseState

@export var player : Player
var anim_player

@export var move_speed := 50.0
var dir : float = 0.0

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void:
	# ---- ATTAQUE ----
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "PlayerAttack")
		return

	# ---- SAUT ----
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = player.JUMP_VELOCITY

	# ---- DEPLACEMENT ----
	dir = Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		player.set_facing(dir > 0.0)

func update(delta : float) -> void:
	if not anim_player:
		anim_player = player.get_animation_player()

	var target := player.MAX_SPEED * dir

	if dir != 0.0:
		player.velocity.x = move_toward(player.velocity.x, target, player.ACCEL * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.DECEL * delta)

	# (sécurité)
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)

	if abs(player.velocity.x) < 0.01:
		Transitioned.emit(self, "PlayerIdle")

func physics_update(delta: float) -> void:
	if abs(player.velocity.x) > 0.01:
		if anim_player and anim_player.has_method("play"):
			anim_player.play("run")

func enter() -> void:
	if player == null:
		var sm := get_parent()
		if sm and sm.get_parent() is Player:
			player = sm.get_parent() as Player
	anim_player = player.get_animation_player()

func exit() -> void:
	pass
