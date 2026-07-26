extends Node

const HeroData = preload("res://Scripts/hero_data.gd")

## Persistent run state (game data store)

## The room the player is currently standing on.
var current_room_id: String = "start"
var current_room_type: String = ""

## Rooms already cleared (passed through) on this run.
var visited: Array[String] = []

## Heroes in hand
var heroes: Array[HeroData] = [
	HeroData.new("Hero The One", 42, 15),
	HeroData.new("Hero Maybe", 30, 12),
	HeroData.new("Hero Backup", 20, 10),
]

func add_hero() -> void:
	print("Appending hero")
	heroes.append(
		HeroData.new("Hero Rescued", 13, 6),
	)

## Call to start a fresh run (e.g. from a title screen or after game over).
func reset() -> void:
	current_room_id = "start"
	current_room_type = ""
	visited.clear()

	heroes = [
		HeroData.new("Hero The One", 42, 15),
		HeroData.new("Hero Maybe", 30, 12),
		HeroData.new("Hero Backup", 20, 10),
	]
