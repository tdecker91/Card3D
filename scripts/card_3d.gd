class_name Card3D
extends Node3D


@export var hover_scale_factor: float = 1.15
@export var hover_pos_move: Vector3 = Vector3(0, 0.8, 0)
@export var move_tween_duration: float = 0.08
@export var rotate_tween_duration: float = 0.15


signal card_pressed()
signal mouse_over_card()
signal mouse_exit_card()


@export var value: int = 0:
	set(v):
		value = v


@export var suit: String = "diamond":
	set(s):
		suit = s
		set_texture()


var position_tween: Tween
var rotate_tween: Tween
var hover_tween: Tween


func set_texture():
	if value and suit:
		var mat = load("res://resources/materials/" + str(suit) + "-" + str(value) + ".tres")
		
		if mat:
			$CardFrontMesh.set_surface_override_material(0, mat)


func set_hovered():
	if hover_tween and hover_tween.is_running:
		hover_tween.kill()
		
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_IN)
	_tween_card_scale(hover_scale_factor)
	_tween_mesh_position(hover_pos_move, move_tween_duration)


func remove_hovered():
	if hover_tween and hover_tween.is_running:
		hover_tween.kill()
		
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_IN)
	_tween_card_scale(1)
	_tween_mesh_position(Vector3.ZERO, move_tween_duration)


func dragging_rotation(rotation):
	if rotate_tween and rotate_tween.is_running:
		rotate_tween.kill()
	
	rotate_tween = create_tween()
	_tween_card_rotation(rotation, rotate_tween_duration)


func animate_to_position(position: Vector3, duration = move_tween_duration):
	if position_tween and position_tween.is_running:
		position_tween.kill()
	
	position_tween = create_tween()
	_tween_card_position(position, duration)
	return position_tween


func _to_string():
	return str(value) + " of " + str(suit)


func _tween_card_scale(scale_factor: float):
	var target_scale = Vector3(scale_factor, scale_factor,1)
	hover_tween.tween_property($".", "scale", target_scale, move_tween_duration)


func _tween_mesh_position(pos: Vector3, duration: float):
	hover_tween.tween_property($CardFrontMesh, "position", pos, duration)


func _tween_card_position(pos: Vector3, duration: float):
	position_tween.tween_property($".", "position", pos, duration)


func _tween_card_rotation(target_rotation, duration):
	rotate_tween.set_ease(Tween.EASE_IN)
	rotate_tween.tween_property($".", "rotation", target_rotation, duration)


func _on_static_body_3d_mouse_entered():
	mouse_over_card.emit()


func _on_static_body_3d_mouse_exited():
	mouse_exit_card.emit()


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		var button = event.button_index
		var pressed = event.pressed
		if button == 1 and pressed == true:
			card_pressed.emit()
