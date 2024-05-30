# hand_3d.gd
# class for the players hand of cards
# adds code for handling:
#  - mouse over/exit card
#  - click and drag
class_name Hand3D
extends CardCollection3D


signal drag_started(card)
signal drag_stopped()


@export var camera: Camera3D
@export var card_swap_tween_duration: float = .12


var card_drag_plane = Plane(Vector3(0, 0, 1), 1.5)
var dragging: bool = false
var drag_left_position = null
var drag_right_position = null
var selected_card: Card3D
var hovered_card: Card3D


func _ready():
	$DropZone.position.z = 1.6
	var dropzone_shape = ConvexPolygonShape3D.new()
	dropzone_shape.points = PackedVector3Array(
		[
			Vector3(-7,2,0),
			Vector3(-7,-2,0),
			Vector3(7,-2,0),
			Vector3(7,2,0)
		]
	)
	$DropZone/CollisionShape3D.shape = dropzone_shape;


#func add_card(card: Card3D):
	#card.card_pressed.connect(_on_card_pressed.bind(card))
	#card.mouse_over_card.connect(_on_card_hover.bind(card))
	#card.mouse_exit_card.connect(_on_card_exit.bind(card))
	#super.add_card(card)
#
#
## remove card from this hand and return it.
## the caller is responsible for adding card else here
## and/or calling queue_free on it
#func remove_card(index: int) -> Card3D:
	#var removed_card = super.remove_card(index)
	#removed_card.card_pressed.disconnect(_on_card_pressed.bind(removed_card))
	#removed_card.mouse_over_card.disconnect(_on_card_hover.bind(removed_card))
	#removed_card.mouse_exit_card.disconnect(_on_card_exit.bind(removed_card))
	#return removed_card


func _input(event):
	if event is InputEventMouseButton:
		if dragging and event.button_index == 1 and !event.pressed:
			_stop_drag()
	elif event is InputEventMouseMotion:
		if dragging:
			pass
			#_handle_drag_event(event)

#
#func _on_card_hover(card: Card3D):
	#if not dragging:
		#hovered_card = card
		#card.set_hovered()
#
#
#func _on_card_exit(card: Card3D):
	#if hovered_card == card:
		#card.remove_hovered()
		#hovered_card = null
#
#
#func _on_card_pressed(card: Card3D):
	#_start_drag(card)


func _start_drag(card: Card3D):
	dragging = true
	card.remove_hovered()
	selected_card = card
	_set_drag_boundaries(card)
	drag_started.emit(card)


func _stop_drag():
	dragging = false
	var card_index = card_indicies[selected_card]
	var hand_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), card_index)
	card_layout_strategy.update_card_position(selected_card, cards.size(), card_index, card_swap_tween_duration)
	selected_card = null
	drag_left_position = null
	drag_right_position = null
	drag_stopped.emit()


func _handle_drag_event(event: InputEventMouseMotion):
	var m: Vector2 = get_viewport().get_mouse_position()
	var position3D = card_drag_plane.intersects_ray(camera.project_ray_origin(m),camera.project_ray_normal(m))
	var card_position = selected_card.global_position
	
	var x_distance = position3D.x - card_position.x
	var y_distance = position3D.y - card_position.y
	
	# add rotation to make dragging cards pretty
	# rotate around y axis for horizontal rotation
	var y_degrees: float = x_distance * 25
	#y_degrees = clamp(y_degrees, -max_drag_y_rotation_deg, max_drag_y_rotation_deg)
	
	# rotate around x axis for vertial rotation
	var x_degrees: float = -y_distance * 25
	#x_degrees = clamp(x_degrees, -max_drag_x_rotation_deg, max_drag_x_rotation_deg)
	var z_degrees: float = 0

	# put degrees in Vector3
	var target_rotation = Vector3(
		deg_to_rad(x_degrees),
		deg_to_rad(y_degrees),
		deg_to_rad(z_degrees)
	)
	 
	# set rotation
	selected_card.dragging_rotation(target_rotation)
	
	# set card position to under mouse
	selected_card.global_position.x = position3D.x
	selected_card.global_position.y = position3D.y
	selected_card.global_position.z = position3D.z
	
	_handle_card_reorder(position3D)


func _set_drag_boundaries(card):
	if cards.size() == 1:
		return
		
	var index = card_indicies[card]
	
	if index > 0:
		drag_left_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), index - 1)
	else:
		drag_left_position = null
		
	if index < cards.size() - 1:
		drag_right_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), index + 1)
	else:
		drag_right_position = null


func _handle_card_reorder(drag_position: Vector3):
	var drag_screen_point = _get_drag_screen_point(drag_position)
	var swapped = true
	
	while swapped:
		var left_screen_point = _get_drag_screen_point(drag_left_position)
		var right_screen_point = _get_drag_screen_point(drag_right_position)
		
		if left_screen_point != null and drag_screen_point.x < left_screen_point.x:
			_handle_swap_left()
		elif drag_right_position != null and drag_screen_point.x > right_screen_point.x:
			_handle_swap_right()
		else:
			swapped = false


func _get_drag_screen_point(position):
	if position != null:
		return camera.unproject_position(position)
	else:
		return null;


func _handle_swap_left():
	var index = card_indicies[selected_card]
	var left_index = index - 1
	var left_card = cards[left_index]
	
	cards[left_index] = selected_card
	cards[index] = left_card
	card_indicies[left_card] = index
	card_indicies[selected_card] = left_index

	_set_drag_boundaries(selected_card)
	card_layout_strategy.update_card_position(left_card, cards.size(), index, card_swap_tween_duration)


func _handle_swap_right():
	var index = card_indicies[selected_card]
	var right_index = index + 1
	var right_card = cards[right_index]
	
	cards[right_index] = selected_card
	cards[index] = right_card
	card_indicies[right_card] = index
	card_indicies[selected_card] = right_index
	
	_set_drag_boundaries(selected_card)
	card_layout_strategy.update_card_position(right_card, cards.size(), index, card_swap_tween_duration)
