class_name PlayerAttack
extends BaseState

@export var player : Player
var anim_player
var last_dir : float = 0.0
var _connected := false

func enter() -> void:
	if player == null:
		var sm := get_parent()
		if sm and sm.get_parent() is Player:
			player = sm.get_parent() as Player

	anim_player = player.get_animation_player()
	player.velocity.x = 0.0

	if anim_player and anim_player.has_method("play"):
		anim_player.play("attack")   # loop doit être OFF dans SpriteFrames

	# Si tu utilises AnimationPlayer un jour, ce signal marchera
	if anim_player and anim_player.has_signal("animation_finished") and not _connected:
		anim_player.animation_finished.connect(_on_anim_finished)
		_connected = true

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void:
	last_dir = Input.get_axis("move_left", "move_right")

func update(delta: float) -> void:
	if not anim_player:
		anim_player = player.get_animation_player()
	if last_dir != 0.0:
		player.set_facing(last_dir > 0.0)

func physics_update(delta: float) -> void:
	# verrouille le déplacement horizontal
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.35)

func exit() -> void:
	if anim_player and anim_player.has_signal("animation_finished"):
		if anim_player.animation_finished.is_connected(_on_anim_finished):
			anim_player.animation_finished.disconnect(_on_anim_finished)
	_connected = false

func _on_anim_finished(anim_name: StringName = &"") -> void:
	# Vrai si on est bien à la fin de l'anim d'attaque
	var is_attack := true
	if anim_player is AnimationPlayer:
		is_attack = String(anim_name).to_lower() == "attack"
	elif anim_player is AnimatedSprite2D:
		# AnimatedSprite2D ne passe pas de nom d'anim au signal
		# On vérifie donc l'anim courante
		is_attack = anim_player.animation == "attack"

	if not is_attack:
		return

	var axis := Input.get_axis("move_left", "move_right")
	var next := "PlayerRun" if abs(axis) > 0.0 else "PlayerIdle"
	Transitioned.emit(self, next)
