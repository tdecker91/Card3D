class_name LineCardLayout
extends CardLayout

var max_width: float = 20:
	set(w):
		max_width = w
		var half_width = max_width / 2.0
		start = Vector3(-half_width,0,0) 
		end = Vector3(half_width,0,0.1)

var start = Vector3(-7,0,0)
var end = Vector3(7,0,0.1)
var card_width: float = 2.5
var padding: float = 0.5


# where the first card will be on the x axis
func _get_hand_start_x(hand_width: float, card_size: float) -> float:
	return (-hand_width / 2) + (card_size / 2)


# how far apart to set each card
func _get_card_offset(num_cards: int, card_size: float) -> float:
	# Calculate required space for cards with padding
	var total_card_space = card_size * num_cards
	var total_padding_space = (num_cards - 1) * padding
	
	if total_card_space + total_padding_space <= max_width:
		# Cards fit within the available space without overlapping
		return card_size + padding
	else:
		# Cards need to overlap
		return (max_width - card_size) / (num_cards - 1)


func calculate_card_positions(num_cards: int) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	var card_offset = _get_card_offset(num_cards, card_width)
	var hand_width = card_width + ((num_cards - 1) * card_offset)
	var start_pos = _get_hand_start_x(hand_width, card_width)
	
	# Position each card
	for i in range(num_cards):
		var i_pos: Vector3 = Vector3(start_pos + (i * card_offset), 0, .001 * i)
		positions.append(i_pos)
	
	return positions


func calculate_card_position_by_index(num_cards: int, index: int):
	var card_offset = _get_card_offset(num_cards, card_width)
	var hand_width = card_width + ((num_cards - 1) * card_offset)
	var start_pos = _get_hand_start_x(hand_width, card_width)
	
	return Vector3(start_pos + (index * card_offset), 0, .001 * index)
