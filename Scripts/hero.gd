extends Node2D

signal hero_clicked

@export var hero_name: String;
@export var age: int;
@export var max_hp: int;
@export var hp: int;
var action_available: bool;

@onready var age_label: Label = $Nameplate/ColorRect/Age
@onready var name_label: Label = $Nameplate/ColorRect/Name
@onready var hp_bar: ColorRect = $Nameplate/ColorRect/HPBar
@onready var hp_rect: ColorRect = $Nameplate/ColorRect/HPBar/HP
@onready var action_taken: Sprite2D = $ActionTaken

var abilities = {
	0: {
		"title": "Great sword",
		"description": "Do 20 damage to one random enemy",
		"target": "enemies",
		"effect": func(enemies):
			var index = randi_range(0, enemies.size() - 1)
			print(enemies.size(), index)
			enemies[index].damage(20),
	},
	1: {
		"title": "Healing aura",
		"description": "Heal all allies for 5hp",
		"target": "party",
		"effect": func(allies):
			for ally in allies:
				ally.set_hp(ally.hp + 5),
	},
	2: {
		"title": "Guard self",
		"description": "Take no damage this turn",
		"target": "self",
		"effect": func(hero):
			hero.status_effects.set("guarded", true),
	}
}
var status_effects = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	age_label.text = str(age);
	name_label.text = hero_name;
	set_hp(hp)
	
func set_hp(new_hp):
	hp = new_hp
	hp_rect.size.x = lerp(0., hp_bar.size.x, float(hp) / max_hp);

func set_action_available(b: bool):
	action_available = b
	# TODO: Maybe expand this to show different stuff for different actions,
	#   e.g. preparing spell or whatever
	action_taken.visible = action_available

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("hero_clicked");

func modify_age(delta: int):
	age += delta
	age_label.text = str(age)
