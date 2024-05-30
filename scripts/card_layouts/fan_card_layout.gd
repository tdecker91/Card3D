class_name FanCardLayout
extends CardLayout

var arc_angle_deg: float = 90.0:
	set(a):
		arc_angle_deg = a
		start_angle = PI/2 + (deg_to_rad(arc_angle_deg) / 2)
		
var arc_radius: float = 7.0

var start_angle = PI/2 + (deg_to_rad(arc_angle_deg) / 2)


func calculate_card_positions(num_cards: int) -> Array[Vector3]:
	var angle_step = deg_to_rad(arc_angle_deg) / (num_cards + 1)
	var positions: Array[Vector3] = []
	
	for i in range(1, num_cards + 1):
		var angle = start_angle - (i * angle_step)
		var x = arc_radius * cos(angle)
		var y = (arc_radius * sin(angle)) - arc_radius
		var position = Vector3(x, y, 0.001 * i)
		positions.append(position)
		
	return positions


func calculate_card_position_by_index(num_cards: int, index: int) -> Vector3:
	var angle_step = deg_to_rad(arc_angle_deg) / (num_cards + 1)
	
	var angle = start_angle - ((index + 1) * angle_step)
	var x = arc_radius * cos(angle)
	var y = (arc_radius * sin(angle)) - arc_radius
	var position = Vector3(x, y, 0.001 * (index + 1))
	
	return position


func calculate_card_rotations(num_cards: int) -> Array[Vector3]:
	var rotations: Array[Vector3] = []
	var angle_step = deg_to_rad(arc_angle_deg) / (num_cards + 1)
	
	for i in range(1, num_cards + 1):
		var angle = start_angle - (i * angle_step)
		var rotation_quat = Quaternion(Vector3(0, 0, 1), angle - PI/2)
		rotations.append(rotation_quat.get_euler())
	
	return rotations


func calculate_card_rotation_by_index(num_cards: int, index: int) -> Vector3:
	var angle_step = deg_to_rad(arc_angle_deg) / (num_cards + 1)
	var angle = start_angle - ((index + 1) * angle_step)
	var rotation_quat = Quaternion(Vector3(0, 0, 1), angle - PI/2)
	return rotation_quat.get_euler()
