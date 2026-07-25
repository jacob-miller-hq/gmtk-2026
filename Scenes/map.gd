extends CanvasLayer

## Full-screen, toggleable Slay-the-Spire-style map.
##
## Toggle with the `toggle_map` action (bound to M below if you haven't set
## one up). The player occupies one room and may only move to rooms that are
## DIRECTLY connected to it. Picking a room emits `room_chosen` — connect that
## in combat.gd to actually start the chosen encounter.

signal room_chosen(room: MapRoom)

@onready var content: Node2D = $Content  # pan/zoom pivot — keeps this scroll-ready

# --- Map definition -------------------------------------------------------
# id, screen position, type, and the ids it leads to.
const MAP := [

	{ "id": "start", "pos": Vector2(960, 960), "type": "start",  "to": ["a1", "a2"] },
	{ "id": "a1",    "pos": Vector2(680, 760), "type": "combat", "to": ["b1", "b2"] },
	{ "id": "a2",    "pos": Vector2(1240, 760), "type": "bones", "to": ["b2", "b3"] },

	{ "id": "b1",    "pos": Vector2(520, 560), "type": "_", "to": ["c1"] },
	{ "id": "b2",    "pos": Vector2(960, 560), "type": "elite",  "to": ["c1", "c2"] },
	{ "id": "b3",    "pos": Vector2(1400, 560), "type": "bones", "to": ["c2"] },

	{ "id": "c1",    "pos": Vector2(700, 360), "type": "elite",   "to": ["boss"] },
	{ "id": "c2",    "pos": Vector2(1220, 360), "type": "bones", "to": ["boss"] },

	{ "id": "boss",  "pos": Vector2(960, 160), "type": "finish",   "to": [] },
]

var _rooms: Dictionary = {}   # id -> MapRoom
var _edges: Array = []        # { line, from, to }
var _current: MapRoom


func _ready() -> void:
	_ensure_input_action()
	hide()
	_build_map()
	_set_current(_rooms["start"])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		toggle()
		get_viewport().set_input_as_handled()


## Public API — call these from a button, combat.gd, anywhere.
func toggle() -> void:
	visible = not visible


func open() -> void:
	visible = true


func close() -> void:
	visible = false


# Register M as the toggle key at runtime if the project doesn't already
# define `toggle_map` in Project Settings > Input Map. Add it there to rebind.
func _ensure_input_action() -> void:
	if not InputMap.has_action("toggle_map"):
		InputMap.add_action("toggle_map")
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_M
		InputMap.action_add_event("toggle_map", ev)


# --- Construction ---------------------------------------------------------
func _build_map() -> void:
	# Pass 1: create every room node.
	for data in MAP:
		var room := MapRoom.new()
		room.name = data["id"]
		room.position = data["pos"]
		room.room_type = data["type"]
		room.z_index = 1  # draw rooms above the connector lines
		content.add_child(room)
		room.selected.connect(_on_room_selected)
		_rooms[data["id"]] = room

	# Pass 2: wire exits and draw a connector line for each edge.
	for data in MAP:
		var from_room: MapRoom = _rooms[data["id"]]
		for to_id in data["to"]:
			var to_room: MapRoom = _rooms[to_id]
			from_room.exits.append(to_room)

			var line := Line2D.new()
			line.points = PackedVector2Array([from_room.position, to_room.position])
			line.width = 6.0
			line.default_color = Color(0.3, 0.32, 0.38)
			content.add_child(line)
			_edges.append({ "line": line, "from": from_room, "to": to_room })


# --- Movement / state -----------------------------------------------------
func _on_room_selected(room: MapRoom) -> void:
	_set_current(room)
	room_chosen.emit(room)
	# TODO: hand off to combat here, e.g. start an encounter from room.room_type.


func _set_current(room: MapRoom) -> void:
	if _current and _current != room:
		_current.set_state(MapRoom.State.VISITED)
	_current = room
	_refresh_states()


func _refresh_states() -> void:
	# Lock everything that isn't the current room or already cleared...
	for id in _rooms:
		var r: MapRoom = _rooms[id]
		if r != _current and r.state != MapRoom.State.VISITED:
			r.set_state(MapRoom.State.LOCKED)

	# ...mark where the player is...
	_current.set_state(MapRoom.State.CURRENT)

	# ...and open up only the rooms directly connected to it.
	for to_room in _current.exits:
		if to_room.state != MapRoom.State.VISITED:
			to_room.set_state(MapRoom.State.REACHABLE)

	# Highlight the edges leaving the current room.
	for e in _edges:
		var active: bool = e["from"] == _current
		e["line"].default_color = Color(0.85, 0.85, 0.5) if active else Color(0.3, 0.32, 0.38)
		e["line"].width = 9.0 if active else 6.0
