class_name CardLayout
extends Resource


# moves cards to where they belong in space
func update_card_positions(cards: Array[Card3D], duration: float):
	var positions = calculate_card_positions(cards.size())
	var rotations = calculate_card_rotations(cards.size())
	
	for i in range(cards.size()):
		var card = cards[i]
		if card != null:
			card.animate_to_position(positions[i], duration)
			card.dragging_rotation(rotations[i])

func update_card_position(card: Card3D, num_cards: int, index: int, duration: float):
	var position = calculate_card_position_by_index(num_cards, index)
	var rotation = calculate_card_rotation_by_index(num_cards, index)
	card.animate_to_position(position, duration)
	card.dragging_rotation(rotation)


func calculate_card_positions(_num_cards: int) -> Array[Vector3]:
	return []


func calculate_card_position_by_index(_num_cards: int, _index: int) -> Vector3:
	return Vector3.ZERO


func calculate_card_rotations(num_cards: int) -> Array[Vector3]:
	var rotations: Array[Vector3] = []
	for i in range(num_cards):
		rotations.append(calculate_card_rotation_by_index(num_cards, i))
		
	return rotations


func calculate_card_rotation_by_index(_num_cards: int, _index: int) -> Vector3:
	return Vector3.ZERO
