class_name PlayerAttack
extends BaseState

@export var player : Player
var anim_player : AnimationPlayer
var dir : float = 0.0
var _connected := false

func enter() -> void:
	# Récupère l'AnimationPlayer du joueur (comme dans Idle/Run)
	anim_player = player.get_animation_player()
	# Démarre l'anim d’attaque une seule fois
	if anim_player:
		# Assure que l'attaque NE BOUCLE PAS (au cas où)
		if anim_player.has_animation("Attack"):
			anim_player.play("Attack")
		# On écoute la fin d’animation pour décider du prochain état
		if not _connected:
			anim_player.animation_finished.connect(_on_anim_finished)
			_connected = true
	
	# On verrouille le déplacement horizontal pendant l'attaque
	player.velocity.x = 0.0

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void:
	# On mémorise la direction tenue pendant l’attaque
	dir = Input.get_axis("left", "right")

func update(delta: float) -> void:
	if not anim_player:
		anim_player = player.get_animation_player()
	# Optionnel: on oriente le sprite pendant l’attaque selon la dernière direction
	if dir != 0.0:
		player.facing_right = dir > 0

func physics_update(delta: float) -> void:
	# Reste immobile pendant l’attaque (petit amorti si jamais une vitesse restait)
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.35)

func exit() -> void:
	# Nettoyage: on débranche le signal pour éviter les doubles connexions
	if anim_player and anim_player.animation_finished.is_connected(_on_anim_finished):
		anim_player.animation_finished.disconnect(_on_anim_finished)
	_connected = false

func _on_anim_finished(anim_name: StringName) -> void:
	# On ne réagit qu’à la fin de l’animation "Attack"
	if anim_name != "Attack":
		return
	# Choix du prochain état: si une direction est tenue, on repart en Run, sinon Idle
	var axis := Input.get_axis("left", "right")
	var next := "PlayerRun" if abs(axis) > 0.0 else "PlayerIdle"
	Transitioned.emit(self, next)
