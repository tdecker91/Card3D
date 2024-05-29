# card_pile_3d.gd
# class for managing cards played on the table
class_name CardPile3D
extends CardCollection3D


func _ready():
	self.card_layout_strategy = PileCardLayout.new()
