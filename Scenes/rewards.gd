extends Control

const RewardCard = preload("res://reward_card.tscn")
const Hero = preload("res://Scenes/hero.tscn")

@onready var hand: Node2D = $Hand

const HERO_POS = [
	Vector2(380, 380),
	Vector2(550, 380),
	Vector2(720, 380),

	Vector2(380, 600),
	Vector2(550, 600),
	Vector2(720, 600),
]

func _ready():
	if Run.current_room_type == "bones":
		Run.add_hero()
		
	# TODO: increase rewards after elite rooms
	var deage_cards = generate_deage_cards()
	hand.add_cards(deage_cards)
	
	for i in Run.heroes.size():
		var hero = Hero.instantiate()
		hero.setup(Run.heroes[i])
		hero.position = HERO_POS[i]
		hero.scale = Vector2(0.8, 0.8)
		hero.connect("hero_clicked", func():
			print("hero clicked")
			var card = hand.selected_card
			if card != null:
				print("card ", card.v)
				hand.discard(card)
				hero.modify_age(card.v)
				# TODO: handle underage heroes
		)
		add_child(hero)

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
