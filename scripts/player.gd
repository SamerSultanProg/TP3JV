extends CharacterBody2D

@export var SPEED: float = 300.0
@onready var sm: Node = $StateMachine

func _physics_process(_delta: float) -> void:
	move_and_slide()
