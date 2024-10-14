"""
Card3D
==============

Script for the Card3D scene

Usage:
	- extend the card_3d scene and to add your custom card details
	- extent Card3D class and apply it to your inherited scene
"""
class_name Card3D
extends Node3D


@export var hover_scale_factor: float = 1.15
@export var hover_pos_move: Vector3 = Vector3(0, 0.7, 0)
@export var move_tween_duration: float = 0.08
@export var rotate_tween_duration: float = 0.15
@export var face_down: bool = false:
	set(_face_down):
		face_down = _face_down
		if face_down:
			$CardMesh.rotation = Vector3(0, deg_to_rad(-180), 0)
		else:
			$CardMesh.rotation = Vector3(0, 0, 0)

signal card_3d_mouse_down()
signal card_3d_mouse_up()
signal card_3d_mouse_over()
signal card_3d_mouse_exit()


var position_tween: Tween
var rotate_tween: Tween
var hover_tween: Tween


func disable_collision():
	$StaticBody3D/CollisionShape3D.disabled = true
	
	
func enable_collision():
	$StaticBody3D/CollisionShape3D.disabled = false


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


func dragging_rotation(drag_rotation):
	if rotate_tween and rotate_tween.is_running:
		rotate_tween.kill()
	
	rotate_tween = create_tween()
	_tween_card_rotation(drag_rotation, rotate_tween_duration)


func animate_to_position(new_position: Vector3, duration = move_tween_duration):
	if position_tween and position_tween.is_running:
		position_tween.kill()
	
	position.z = new_position.z # set z to prevent transition spring from making card go below another card
	position_tween = create_tween()
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.set_trans(Tween.TRANS_SPRING)
	_tween_card_position(new_position, duration)
	return position_tween


func _tween_card_scale(scale_factor: float):
	var target_scale = Vector3(scale_factor, scale_factor,1)
	hover_tween.tween_property($".", "scale", target_scale, move_tween_duration)


func _tween_mesh_position(pos: Vector3, duration: float):
	hover_tween.tween_property($CardMesh, "position", pos, duration)


func _tween_card_position(pos: Vector3, duration: float):
	position_tween.tween_property($".", "position", pos, duration)


func _tween_card_rotation(target_rotation, duration):
	rotate_tween.set_ease(Tween.EASE_IN)
	rotate_tween.tween_property($".", "rotation", target_rotation, duration)


func _on_static_body_3d_mouse_entered():
	card_3d_mouse_over.emit()


func _on_static_body_3d_mouse_exited():
	card_3d_mouse_exit.emit()


func _on_static_body_3d_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		var button = event.button_index
		var pressed = event.pressed
		if button == 1 and pressed == true:
			card_3d_mouse_down.emit()
		elif button == 1 and pressed == false:
			card_3d_mouse_up.emit()
