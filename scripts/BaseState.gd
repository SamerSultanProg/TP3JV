@abstract class_name BaseState
extends Node

signal Transitioned(state, new_state_name)

@abstract func handle_inputs(input_event: InputEvent) -> void
@abstract func update(delta: float) -> void
@abstract func physics_update(delta: float) -> void
@abstract func enter() -> void
@abstract func exit() -> void
