class_name StackCardLayout
extends CardLayout


@export var distance: float = 0.8


func calculate_card_positions(num_cards: int) -> Array[Vector3]:
	var positions: Array[Vector3] = []

	for i in range(num_cards):
		positions.append(Vector3(0,i * -distance,.01 * i))

	return positions


func calculate_card_position_by_index(_num_cards: int, index: int) -> Vector3:
	return Vector3(0,index * -distance,.01 * index)


func calculate_card_rotations(num_cards: int) -> Array[Vector3]:
	var rotations: Array[Vector3] = []

	for i in range(num_cards):
		rotations.append(Vector3.ZERO)
	
	return rotations


func calculate_card_rotation_by_index(_num_cards: int, _index: int) -> Vector3:
	return Vector3.ZERO
