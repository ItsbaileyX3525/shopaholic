extends StaticBody3D
@onready var player: CharacterBody3D = $"../../../../Player"
@onready var dealer: Node3D = $"../.."
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var sweet_deal: AudioStreamPlayer3D = $"../../SweetDeal"

func show_dealer() -> void:
	dealer.visible = true
	collision_shape_3d.disabled = false
	sweet_deal.play()

func _ready() -> void:
	if Globals.on_day == 2:
		show_dealer()

func interact() -> void:
	player.show_upgrades()
	
func purchase(item: String) -> void:
	if item == "PRICE":
		if player.coins >= 20:
			player.modify_coins(-20)
			Globals.food_deduction += 1
	elif item == "MULTIPLIER":
		if player.coins >= 15:
			player.modify_coins(-15)
			Globals.multiplier += 0.25
	elif item == "SPEED":
		if player.coins >= 10:
			player.modify_coins(-10)
			Globals.bonus_speed += 0.8
			player.speed += 0.8
