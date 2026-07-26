extends Node2D

signal clicked

@onready var hp_bar: ColorRect = $Nameplate/ColorRect/HPBar
@onready var hp_rect: ColorRect = $Nameplate/ColorRect/HPBar/HP
@onready var action_label: Label = $Action

@export var max_hp: int = 20
var hp: int
var intended_action: String
var abilities = {
	"attacking": func(target: Node2D):
		target.damage(randi_range(2, 3))
}

func setup():
	hp = max_hp
	hp_rect.size.x = lerp(0., hp_bar.size.x, float(hp) / max_hp);

func choose_action():
	intended_action = "attacking" # TODO
	action_label.text = intended_action

func take_action(heroes: Array[Node2D]):
	var action = abilities.get(intended_action)
	for hero in heroes:
		print(action, hero)
		action.call(hero)
	intended_action = ""

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("clicked");

func damage(amount: int):
	hp -= amount
	hp_rect.size.x = lerp(0., hp_bar.size.x, float(hp) / max_hp);
