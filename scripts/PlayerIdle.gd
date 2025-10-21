class_name PlayerIdle
extends BaseState

@export var player : Player
var anim_player : AnimationPlayer

func enter():
	anim_player = player.get_animation_player()
	

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	var dir : float = Input.get_axis("left", "right")

	if (dir != 0):
		Transitioned.emit(self, "PlayerRun")

func update(delta: float) -> void:
	if not anim_player :
		anim_player = player.get_animation_player()

func physics_update(delta: float) -> void:
	if not anim_player : return

	anim_player.play("Idle")

func exit() -> void:
	pass
