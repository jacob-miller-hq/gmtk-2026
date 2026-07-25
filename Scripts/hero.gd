extends Node2D

signal hero_clicked

@export var hero_name: String;
@export var age: int;
@export var max_hp: int;
@export var hp: int;

@onready var age_label: Label = $Nameplate/ColorRect/Age
@onready var name_label: Label = $Nameplate/ColorRect/Name
@onready var hp_bar: ColorRect = $Nameplate/ColorRect/HPBar
@onready var hp_rect: ColorRect = $Nameplate/ColorRect/HPBar/HP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	age_label.text = str(age);
	name_label.text = hero_name;
	hp_rect.size.x = lerp(0., hp_bar.size.x, float(hp) / max_hp);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("hero_clicked");
