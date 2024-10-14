extends Node3D

@onready var monster: BattleCard3D = $Monster
@onready var play_zone: CardCollection3D = $DragController/PlayZone

var card_database = BattleCards.new()

func _ready():
	add_card("pikachu")
	add_card("devil")
	add_card("spider")
	add_card("dragon")


func add_card(card_id):
	var scene = load("res://example_battle/scenes/battle_card_3d.tscn")
	var battle_card_3d: BattleCard3D = scene.instantiate()
	var card_data: Dictionary = card_database.database[card_id]

	battle_card_3d.id = card_data["id"]
	battle_card_3d.front_material_path = card_data["front_material_path"]
	battle_card_3d.damage = card_data["damage"]

	var hand: CardCollection3D = $DragController/CardCollection3D
	hand.append_card(battle_card_3d)


func _on_play_zone_card_added(card: BattleCard3D):
	if !monster:
		return

	var index = play_zone.card_indicies[card]
	play_zone.remove_card(index)
	add_child(card)
	card.queue_free()
	monster.health -= card.damage
	if monster.health <= 0:
		$DragController/PlayZone.play_enabled = false
		monster.queue_free()
