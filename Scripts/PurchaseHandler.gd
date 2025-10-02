extends StaticBody3D
@onready var order_npc: StaticBody3D = $"../../OrderNPC/Collider"

func interact() -> void:
	order_npc.steal()
