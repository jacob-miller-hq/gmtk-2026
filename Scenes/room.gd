class_name MapRoom
extends Area2D

## A single node on the map. Emits `selected` when the player clicks it
## while it is REACHABLE from their current room. 
## For now I have it drawing itself as a colored circle, with an attached icon.

enum State { LOCKED, REACHABLE, CURRENT, VISITED }

signal selected(room: MapRoom)

const RADIUS := 44.0

const TYPE_ICONS := {
	"bones": preload("res://Sprites/bones.png"),
	"elite": preload("res://Sprites/elite.png"),
}

const ICON_SIZE := 56.0

## start / combat / elite / boss / rest / shop
@export var room_type: String = "combat"

## Rooms you can travel TO from here. Directed edges = no backtracking.
var exits: Array[MapRoom] = []
var state: State = State.LOCKED

var _hovered := false


func _ready() -> void:
	# Build the clickable area
	input_pickable = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	add_child(shape)

	input_event.connect(_on_input_event)
	mouse_entered.connect(func() -> void:
		_hovered = true
		queue_redraw())
	mouse_exited.connect(func() -> void:
		_hovered = false
		queue_redraw())


func set_state(s: State) -> void:
	state = s
	queue_redraw()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed \
	and state == State.REACHABLE:
		selected.emit(self)


func _draw() -> void:
	var fill := _state_color()
	if _hovered and state == State.REACHABLE:
		fill = fill.lightened(0.25)

	draw_circle(Vector2.ZERO, RADIUS, fill)

	# A bright ring makes the current room and the valid choices pop.
	if state == State.REACHABLE:
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, Color.WHITE, 4.0, true)
	elif state == State.CURRENT:
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, Color(1, 0.9, 0.3), 5.0, true)

	# Type glyph in the middle.
	var glyph := _type_glyph()
	if glyph != "":
		var font := ThemeDB.fallback_font
		var font_size := 40
		var size := font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, Vector2(-size.x / 2.0, size.y / 3.0), glyph,
			HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.05, 0.05, 0.08))
			
	# Decorative icons
	if TYPE_ICONS.has(room_type):
		var tex: Texture2D = TYPE_ICONS[room_type]
		var rect := Rect2(RADIUS + 12.0, -ICON_SIZE / 2.0, ICON_SIZE, ICON_SIZE)
		draw_texture_rect(tex, rect, false)


func _state_color() -> Color:
	match state:
		State.CURRENT:   return Color(1.0, 0.85, 0.3)    # gold  – you are here
		State.REACHABLE: return Color(0.45, 0.75, 0.45)  # green – you may go here
		State.VISITED:   return Color(0.35, 0.4, 0.4)    # grey  – already cleared
		_:               return Color(0.2, 0.22, 0.28)   # dark  – locked / unknown


func _type_glyph() -> String:
	match room_type:
		"start":  return "S"
		"elite":  return "E"
		"bones":  return "B"
		"finish": return "F"
		_:        return ""  # plain combat room
