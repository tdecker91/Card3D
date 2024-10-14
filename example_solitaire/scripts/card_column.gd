class_name CardColumn
extends CardCollection3D

func can_insert_card(card: FaceCard3D, _from_collection) -> bool:
	if cards.size() == 0:
		return true

	var last_card = cards[cards.size() - 1]
	var is_prior_rank = card.rank == last_card.rank - 1
	var is_opposite_color = false;

	if (card.suit == FaceCards.Suit.HEART or card.suit == FaceCards.Suit.DIAMOND) and (last_card.suit == FaceCards.Suit.CLUB or last_card.suit == FaceCards.Suit.SPADE):
		is_opposite_color = true
	elif (last_card.suit == FaceCards.Suit.HEART or last_card.suit == FaceCards.Suit.DIAMOND) and (card.suit == FaceCards.Suit.CLUB or card.suit == FaceCards.Suit.SPADE):
		is_opposite_color = true

	return last_card.face_down or (is_opposite_color and is_prior_rank)


func can_reorder_card(_card: FaceCard3D) -> bool:
	return false


func can_select_card(card: FaceCard3D) -> bool:
	var card_index = card_indicies[card]
	
	return !card.face_down or card_index == (cards.size() - 1)
