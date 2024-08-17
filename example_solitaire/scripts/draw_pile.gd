class_name DrawPile
extends CardCollection3D

func can_insert_card(_card: FaceCard3D, _from_collection) -> bool:
	return false


func can_select_card(_card: FaceCard3D) -> bool:
	return true


func can_reorder_card(_card: FaceCard3D) -> bool:
	return false


func can_remove_card(_card: FaceCard3D) -> bool:
	return true
