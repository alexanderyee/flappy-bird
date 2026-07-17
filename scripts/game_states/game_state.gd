@abstract
class_name GameState
extends Node

signal transitioned(GameState)

@abstract func enter() -> void

@abstract func exit() -> void
