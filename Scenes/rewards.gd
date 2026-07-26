extends Control

const RewardCard = preload("res://reward_card.tscn")

@onready var hand: Node2D = $Hand

@export var heroes: Array[Node2D] = []

func _ready():
	# TODO: increase rewards after elite rooms
	var deage_cards = generate_deage_cards()
	hand.add_cards(deage_cards)
	for hero in heroes:
		hero.connect("hero_clicked", func():
			print("hero clicked")
			var card = hand.selected_card
			if card != null:
				print("card ", card.v)
				hand.discard(card)
				hero.modify_age(card.v)
				# TODO: handle underage heroes
		)

func generate_deage_cards(target_reward: int = 15):
	var rewards: Array[Node2D] = []
	while target_reward > 0:
		var value = randi_range(3, min(target_reward, 10))
		target_reward -= value
		var card = RewardCard.instantiate()
		card.set_value(value)
		rewards.push_back(card)
	return rewards

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/map.tscn")
