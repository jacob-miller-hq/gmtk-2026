extends Node2D

signal hero_clicked

# Authoring seeds. Only used when a Hero is placed directly in a scene with no
# run data injected (e.g. the display hero in rewards.tscn). Combat heroes
# ignore these — they receive their stats through setup(data).
@export var hero_name: String = "Hero"
@export var age: int = 40
@export var max_hp: int = 15
@export var hero_textures: Dictionary[String, Texture] = {}

# HeroData is the single source of truth for a hero's live stats. Combat heroes
# get it from Run.heroes via setup(); a standalone hero builds its own from the
# exported seeds in _ready(). The node never keeps a separate copy of the stats.
var data: HeroData

var action_available: bool
var status_effects = {}

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var age_label: Label = $Nameplate/ColorRect/Age
@onready var name_label: Label = $Nameplate/ColorRect/Name
@onready var hp_bar: ColorRect = $Nameplate/ColorRect/HPBar
@onready var hp_rect: ColorRect = $Nameplate/ColorRect/HPBar/HP
@onready var action_taken: Sprite2D = $ActionTaken

# Passthrough so existing `hero.hp` reads/writes (enemy attacks, healing effects,
# death checks) hit the persistent HeroData rather than a local copy.
# We may need to do similar accessors for other properties that change over time (!!)
var hp: int:
	get:
		return data.hp if data != null else 0
	set(value):
		if data != null:
			data.hp = value
		_refresh_hp_bar()

var abilities = {
	0: {
		"title": "Great sword",
		"description": "Do 10 damage to one random enemy",
		"target": "enemies",
		"effect": func(enemies):
			var index = randi_range(0, enemies.size() - 1)
			print(enemies.size(), index)
			enemies[index].damage(20),
	},
	1: {
		"title": "Healing aura",
		"description": "Heal all allies for 2hp",
		"target": "party",
		"effect": func(allies):
			for ally in allies:
				ally.heal(2),
	},
	2: {
		"title": "Guard self",
		"description": "Take no damage this turn",
		"target": "self",
		"effect": func(hero):
			hero.status_effects.set("guarded", true),
	}
}

# Inject persistent data before the node enters the tree (combat heroes).
func setup(d: HeroData) -> void:
	data = d
	match(data.hero_name):
		"Hero The One":
			abilities.erase(1)
		"Hero Maybe":
			if data.age > 50:
				abilities.erase(0)
				abilities.erase(1)
		"Hero Backup":
			abilities.erase(0)
		"Hero Rescued":
			abilities.set(0, {
				"title": "Suppressing fire",
				"description": "Do 3-5 damage to all enemies",
				"target": "enemies",
				"effect": func(enemies):
					for enemy in enemies:
						enemy.damage(randi_range(3, 5))
			})

func _ready() -> void:
	if data == null:
		# Standalone hero placed in a scene with no run data: back it with its
		# own HeroData built from the exported seed values.
		data = HeroData.new(hero_name, age, max_hp)
	age_label.text = str(data.age)
	name_label.text = data.hero_name
	sprite_2d.texture = hero_textures.get(data.hero_name)
	_refresh_hp_bar()

func set_hp(new_hp: int) -> void:
	hp = new_hp   # routes through the setter: writes data.hp and refreshes the bar

func damage(amount: int):
	if status_effects.get("guarded"):
		return
	hp -= amount
	
func heal(amount: int):
	if hp + amount >= data.max_hp:
		hp = data.max_hp
	else:
		hp += amount

func _refresh_hp_bar() -> void:
	if hp_rect == null or data == null:
		return
	hp_rect.size.x = lerp(0.0, hp_bar.size.x, float(data.hp) / data.max_hp)

func set_action_available(b: bool):
	action_available = b
	# TODO: Maybe expand this to show different stuff for different actions,
	#   e.g. preparing spell or whatever
	action_taken.visible = action_available

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("hero_clicked")

func modify_age(delta: int):
	data.age += delta
	age_label.text = str(data.age)
	heal(-delta)
