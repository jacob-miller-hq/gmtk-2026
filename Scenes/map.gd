extends CanvasLayer

## Dual-purpose map, controlled by the `is_screen` flag:
##
##   is_screen = true  -> Standalone CHOOSER screen (start of game, and between
##                        combats after rewards). Always visible; rooms are
##                        clickable; picking one saves the move to Run and
##                        change_scene()s into combat.
##
##   is_screen = false -> Frozen REFERENCE overlay inside combat. Hidden by
##                        default; press M to peek, Close/M to hide. Rooms are
##                        frozen and don't respond.
##
## Leave it true on map.tscn itself (the chooser). Set it to false on the Map
## instance you drop inside combat.tscn.

signal room_chosen(room: MapRoom)

@export var is_screen: bool = true

@onready var content: Node2D = $Content
@onready var background: ColorRect = $Background

# --- Map definition -------------------------------------------------------
const MAP := [
	{ "id": "start", "pos": Vector2(960, 960), "type": "start",  "to": ["bones01", "bones02"] },

	{ "id": "bones01",    "pos": Vector2(680, 760), "type": "bones", "to": ["reg01", "reg02"] },
	{ "id": "bones02",    "pos": Vector2(1240, 760), "type": "bones", "to": ["reg02", "reg03"] },

	{ "id": "reg01",    "pos": Vector2(520, 560), "type": "combat", "to": ["elite01"] },
	{ "id": "reg02",    "pos": Vector2(960, 560), "type": "combat", "to": ["elite01", "elite02"] },
	{ "id": "reg03",    "pos": Vector2(1400, 560), "type": "combat", "to": ["elite02"] },

	{ "id": "elite01",    "pos": Vector2(700, 360), "type": "elite", "to": ["children"] },
	{ "id": "elite02",    "pos": Vector2(1220, 360), "type": "elite", "to": ["children"] },

	{ "id": "children",  "pos": Vector2(960, 160), "type": "finish",   "to": [] },
]

var _rooms: Dictionary = {}   # id -> MapRoom
var _edges: Array = []        # { line, from, to }
var _current: MapRoom


func _ready() -> void:
	_ensure_input_action()
	_build_map()
	_restore_from_run()

	# Close button only makes sense for the in-combat overlay.
	if has_node("CloseButton"):
		$CloseButton.visible = not is_screen

	if is_screen:
		# Chooser: always shown, clicks reach the Area2D rooms.
		visible = true
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		# Overlay: hidden until the player peeks; blocks clicks to the fight
		# behind it while open.
		hide()
		background.mouse_filter = Control.MOUSE_FILTER_STOP


func _unhandled_input(event: InputEvent) -> void:
	# M peeks / hides the frozen overlay during a fight. No-op on the chooser.
	if not is_screen and event.is_action_pressed("toggle_map"):
		visible = not visible
		get_viewport().set_input_as_handled()


func open() -> void:
	visible  = true
	

func close() -> void:
	visible = false
	

func toggle() -> void:
	visible = not visible


# --- Input action ---------------------------------------------------------
func _ensure_input_action() -> void:
	if not InputMap.has_action("toggle_map"):
		InputMap.add_action("toggle_map")
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_M
		InputMap.action_add_event("toggle_map", ev)


# --- Construction ---------------------------------------------------------
func _build_map() -> void:
	for data in MAP:
		var room := MapRoom.new()
		room.name = data["id"]
		room.position = data["pos"]
		room.room_type = data["type"]
		content.add_child(room)
		room.selected.connect(_on_room_selected)
		_rooms[data["id"]] = room

	for data in MAP:
		var from_room: MapRoom = _rooms[data["id"]]
		for to_id in data["to"]:
			var to_room: MapRoom = _rooms[to_id]
			from_room.exits.append(to_room)

			var line := Line2D.new()
			line.points = PackedVector2Array([from_room.position, to_room.position])
			line.width = 6.0
			line.default_color = Color(0.3, 0.32, 0.38)
			line.z_index = -1
			content.add_child(line)
			_edges.append({ "line": line, "from": from_room, "to": to_room })


# Draw all visited rooms with VISITED color
func _restore_from_run() -> void:
	for id in Run.visited:
		if _rooms.has(id):
			_rooms[id].set_state(MapRoom.State.VISITED)
	_set_current(_rooms[Run.current_room_id])


# --- Selection ------------------------------------------------------------
func _on_room_selected(room: MapRoom) -> void:
	if not is_screen:
		return  # frozen overlay — rooms don't respond during a fight

	# Commit the move into the Run, then drop into combat for this room.
	if not Run.visited.has(Run.current_room_id):
		Run.visited.append(Run.current_room_id)
	Run.current_room_id = room.name
	Run.current_room_type = room.room_type
	
	# Signal the other scenes to pass room parameters (TODO: we might not need this)
	room_chosen.emit(room)
	
	is_screen = false
	hide()
	get_tree().change_scene_to_file("res://Scenes/combat.tscn")


func _set_current(room: MapRoom) -> void:
	if _current and _current != room:
		_current.set_state(MapRoom.State.VISITED)
	_current = room
	_refresh_states()


func _refresh_states() -> void:
	for id in _rooms:
		var r: MapRoom = _rooms[id]
		if r != _current and r.state != MapRoom.State.VISITED:
			r.set_state(MapRoom.State.LOCKED)

	_current.set_state(MapRoom.State.CURRENT)

	for to_room in _current.exits:
		if to_room.state != MapRoom.State.VISITED:
			to_room.set_state(MapRoom.State.REACHABLE)

	for e in _edges:
		var active: bool = e["from"] == _current
		e["line"].default_color = Color(0.85, 0.85, 0.5) if active else Color(0.3, 0.32, 0.38)
		e["line"].width = 9.0 if active else 6.0
