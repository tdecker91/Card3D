class_name SuitDiscard
extends CardCollection3D

func can_insert_card(card: FaceCard3D, from_collection: CardCollection3D) -> bool:
	if from_collection.card_indicies.has(card) and from_collection.card_indicies[card] < from_collection.cards.size() - 1:
		return false

	if cards.size() == 0:
		return card.rank == FaceCards.Rank.ACE

	var last_card = cards[cards.size() - 1]
	var is_next_rank = (card.rank == last_card.rank + 1) or (last_card.rank == FaceCards.Rank.ACE and card.rank == FaceCards.Rank.TWO)
	var is_same_suit = last_card.suit == card.suit
	
	return is_next_rank and is_same_suit


func can_reorder_card(_card: FaceCard3D) -> bool:
	return false


func can_remove_card(_card: FaceCard3D) -> bool:
	return false


func can_select_card(_card: FaceCard3D) -> bool:
	return false
