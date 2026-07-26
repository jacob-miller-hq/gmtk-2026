class_name HeroData
extends RefCounted

var hero_name: String
var age: int
var max_hp: int
var hp: int

func _init(_name := "Hero", _age := 40, _max_hp := 15) -> void:
	hero_name = _name
	age = _age
	max_hp = _max_hp
	hp = _max_hp
