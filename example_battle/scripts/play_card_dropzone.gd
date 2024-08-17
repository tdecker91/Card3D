class_name PlayCardDropzone
extends CardCollection3D


@export var play_enabled: bool = true


func can_insert_card(_card: BattleCard3D, _from_collection) -> bool:
	return play_enabled


func can_reorder_card(_card: BattleCard3D) -> bool:
	return false


func can_select_card(_card: BattleCard3D) -> bool:
	return false


func can_remove_card(_card: BattleCard3D) -> bool:
	return false
