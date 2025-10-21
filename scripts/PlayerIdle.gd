class_name PlayerIdle
extends BaseState

@export var player : Player
var anim_player

func enter() -> void:
	if player == null:
		var sm := get_parent()
		if sm and sm.get_parent() is Player:
			player = sm.get_parent() as Player
	anim_player = player.get_animation_player()
	if anim_player and anim_player.has_method("play"):
		anim_player.play("idle")

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void:
	# Attaque
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "PlayerAttack")
		return
	# Saut
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = player.JUMP_VELOCITY
	# Déplacement → Run
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		Transitioned.emit(self, "PlayerRun")

func update(delta: float) -> void:
	if not anim_player:
		anim_player = player.get_animation_player()

func physics_update(delta: float) -> void:
	if anim_player and anim_player.has_method("play"):
		anim_player.play("idle")

func exit() -> void:
	pass
