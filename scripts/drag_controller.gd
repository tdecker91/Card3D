# drag_controller.gd
# class for enabling click and drag of Card3D nodes
class_name DragController
extends Node3D


signal drag_started(card)
signal drag_stopped()


@export var card_collections: Array[CardCollection3D] = []
@export var max_drag_y_rotation_deg: int = 65
@export var max_drag_x_rotation_deg: int = 65


var card_drag_plane = Plane(Vector3(0, 0, 1), 1.5): # plane card is moved across on drag
	set(plane):
		card_drag_plane = plane

var _camera: Camera3D # camera used for determining where mouse is on drag plane
var _dragging_card: Card3D # card that is being dragged
var _drag_from_collection: CardCollection3D # collection card being dragged from
var _dragging: bool = false
var _hovered_collection: CardCollection3D # collection about to drop card into
var _drag_left_position = null
var _drag_right_position = null


func _ready():
	var window = get_window()
	_camera = window.get_camera_3d()
	
	for collection in card_collections:
		collection.card_selected.connect(_on_collection_card_selected.bind(collection))
		collection.mouse_enter_drop_zone.connect(_on_collection_mouse_enter_drop_zone.bind(collection))
		collection.mouse_exit_drop_zone.connect(_on_collection_mouse_exit_drop_zone.bind(collection))


func _input(event):
	if event is InputEventMouseButton:
		if _dragging and event.button_index == 1 and !event.pressed:
			var m: Vector2 = get_viewport().get_mouse_position()
			_stop_drag(m)
	elif event is InputEventMouseMotion:
		if _dragging:
			_handle_drag_event(event)


func _on_collection_card_selected(card: Card3D, collection: CardCollection3D):
	_drag_card_start(card, collection)


func _on_collection_mouse_enter_drop_zone(collection: CardCollection3D):
	_hovered_collection = collection


func _on_collection_mouse_exit_drop_zone(_collection: CardCollection3D):
	if _hovered_collection != _drag_from_collection:
		_hovered_collection.execute_card_strategy()
		
	_hovered_collection = null


func _stop_drag(mouse_position: Vector2):
	if _hovered_collection == null or _hovered_collection == _drag_from_collection:
		return_card_to_collection(mouse_position)
	elif _hovered_collection != null and _hovered_collection != _drag_from_collection:
		drop_card_to_another_collection(mouse_position)
		
	_drag_from_collection.disable_drop_zone()

	_dragging = false
	_dragging_card = null
	_drag_from_collection = null
	
	for collection in card_collections:
		if collection.insertable:
			collection.disable_drop_zone()
			
		if collection.draggable:
			collection.selection_disabled = false
	
	drag_stopped.emit()


func return_card_to_collection(mouse_position: Vector2):
	var current_index = _drag_from_collection.card_indicies[_dragging_card]
	var new_index = _drag_from_collection.get_card_index_at_point(mouse_position)
	new_index = clamp(new_index, 0, _drag_from_collection.cards.size() - 1)
	
	if current_index != new_index:
		_drag_from_collection.remove_card(current_index)
		_drag_from_collection.insert_card(_dragging_card, new_index)
		
	_drag_from_collection.execute_card_strategy()


func drop_card_to_another_collection(mouse_position: Vector2):
	var card_index = _drag_from_collection.card_indicies[_dragging_card]
	var global_position = _drag_from_collection.cards[card_index].global_position
	var c = _drag_from_collection.remove_card(card_index)
	
	if _hovered_collection.reorderable:
		var index = _hovered_collection.get_card_index_at_point(mouse_position)
		_hovered_collection.insert_card(c, index)
	else:
		_hovered_collection.add_card(c)
	
	c.remove_hovered()
	c.global_position = global_position


func _drag_card_start(card: Card3D, drag_from_collection: CardCollection3D):
	_dragging = true
	_drag_from_collection = drag_from_collection
	_dragging_card = card
	
	for collection in card_collections:
		if collection.insertable:
			collection.enable_drop_zone()
			
		if collection.draggable:
			collection.selection_disabled = true
	
	_drag_from_collection.enable_drop_zone()
	
	drag_started.emit(card)


func _handle_drag_event(event: InputEventMouseMotion):
	var m: Vector2 = get_viewport().get_mouse_position()
	var position3D = card_drag_plane.intersects_ray(_camera.project_ray_origin(m),_camera.project_ray_normal(m))
	var card_position = _dragging_card.global_position
	
	var x_distance = position3D.x - card_position.x
	var y_distance = position3D.y - card_position.y
	
	# add rotation to make dragging cards pretty
	# rotate around y axis for horizontal rotation
	var y_degrees: float = x_distance * 25
	y_degrees = clamp(y_degrees, -max_drag_y_rotation_deg, max_drag_y_rotation_deg)
	
	# rotate around x axis for vertial rotation
	var x_degrees: float = -y_distance * 25
	x_degrees = clamp(x_degrees, -max_drag_x_rotation_deg, max_drag_x_rotation_deg)
	var z_degrees: float = 0

	# put degrees in Vector3
	var target_rotation = Vector3(
		deg_to_rad(x_degrees),
		deg_to_rad(y_degrees),
		deg_to_rad(z_degrees)
	)
	 
	# set rotation
	_dragging_card.dragging_rotation(target_rotation)
	
	# set card position to under mouse
	_dragging_card.global_position.x = position3D.x
	_dragging_card.global_position.y = position3D.y
	_dragging_card.global_position.z = position3D.z
	
	if _hovered_collection != null and _hovered_collection.reorderable:
		var drag_screen_point = _get_drag_screen_point(position3D)
		_hovered_collection.on_drag_hover(_dragging_card, drag_screen_point)


func _get_drag_screen_point(position):
	if position != null:
		return _camera.unproject_position(position)
	else:
		return null
		
