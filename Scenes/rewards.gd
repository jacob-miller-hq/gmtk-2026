extends Control

## Placeholder rewards screen shown after a won combat.
## "Continue" returns to the map screen, where the player picks the next room.

func _ready() -> void:
	if Run.current_room_type == "bones":
		Run.add_hero()

	$Continue.grab_focus()  # so Enter/Space also works



func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/map.tscn")
