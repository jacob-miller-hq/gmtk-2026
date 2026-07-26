extends Node

## Persistent run state (game data store)

## The room the player is currently standing on.
var current_room_id: String = "start"

## Rooms already cleared (passed through) on this run.
var visited: Array[String] = []

## Available Heroes: the heroes player can choose from
var available_heroes: Array[String] = []

## Heroes in hand
var heroes: Array[String] = []

## Call to start a fresh run (e.g. from a title screen or after game over).
func reset() -> void:
	current_room_id = "start"
	visited.clear()
	## TODO: reset heroes
