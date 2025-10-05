extends Node3D
@onready var redroom: Node3D = $"../redroom"
@onready var camera_3d: Camera3D = $"../redroom/Camera3D"
@onready var player: CharacterBody3D = $"../../Player"
@onready var audio_stream_player: AudioStreamPlayer = $"../redroom/jumpscare"
@onready var whynopay: AudioStreamPlayer = $"../redroom/whynopay"
@onready var golden_interactables_spawns: Node3D = $SpecialItems/GoldenInteractablesSpawns
@onready var box_spawn: Marker3D = $SpecialItems/GoldenInteractablesSpawns/BoxSpawn
@onready var bucket_spawn: Marker3D = $SpecialItems/GoldenInteractablesSpawns/BucketSpawn
@onready var chest_spawn: Marker3D = $SpecialItems/GoldenInteractablesSpawns/ChestSpawn
@onready var special_items: Node3D = $SpecialItems

var items_available: int = 0
var default_position: Vector3 = Vector3(-2.648,-34.903,31.403)
var scare_position: Vector3 = Vector3(-2.748,-32.957,-1.134)

const CHEST = preload("uid://ba75llr687o5j")
const BOX = preload("uid://dcpxoaqjjl4j")
const BUCKET = preload("uid://dmxgd41n6ov2x")


func _ready() -> void:
	var children = get_child(0).get_children()
	for e in children:
		items_available += 1

	#Spawn Golden item (which is actually cursed)
	randomize()
	var rng = randi_range(0,2)  # 0 = box, 1 = bucket, 2 = chest (all cursed)
	if rng == 0:
		print("box spawned (cursed)")
		var item = BOX.instantiate()
		item.position = box_spawn.position
		var light = OmniLight3D.new()
		light.light_energy = 16
		light.position = Vector3(box_spawn.get_meta("LightPos"))
		light.light_color = Color("8b00ff")  # Purple color for cursed
		item.add_child(light)
		var static_body = StaticBody3D.new()
		static_body.name = "coins-cursed"
		var shape = BoxShape3D.new()
		shape.size = Vector3(0.24, 0.24, 0.23)
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = shape
		static_body.add_child(collision_shape)
		item.add_child(static_body)
		special_items.add_child(item)
	elif rng == 1:
		print("Bucket spawned (cursed)")
		var item = BUCKET.instantiate()
		item.position = bucket_spawn.position
		var light = OmniLight3D.new()
		light.light_energy = 16
		light.position = Vector3(bucket_spawn.get_meta("LightPos"))
		light.light_color = Color("8b00ff")  # Purple color for cursed
		item.add_child(light)
		var static_body = StaticBody3D.new()
		static_body.name = "coins-cursed"
		var shape = BoxShape3D.new()
		shape.size = Vector3(0.15, 0.13, 0.15)
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = shape
		static_body.add_child(collision_shape)
		item.add_child(static_body)
		special_items.add_child(item)
	elif rng == 2:
		print("Chest spawned (cursed)")
		var item = CHEST.instantiate()
		item.position = chest_spawn.position
		var light = OmniLight3D.new()
		light.light_energy = 16
		light.position = Vector3(chest_spawn.get_meta("LightPos"))
		light.light_color = Color("8b00ff")  # Purple color for cursed
		item.add_child(light)
		var static_body = StaticBody3D.new()
		static_body.name = "coins-cursed"
		var shape = BoxShape3D.new()
		shape.size = Vector3(0.26, 0.25, 0.27)
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = shape
		static_body.add_child(collision_shape)
		item.add_child(static_body)
		special_items.add_child(item)

func check_interactables() -> void:
	items_available -= 1
	if items_available <= 0:
		if player.coins >= 0:
			print("Player had enough")
			return
		camera_3d.position = default_position
		await get_tree().create_timer(8.2).timeout #Wait for animation to finsih
		camera_3d.current = true
		whynopay.play()
		player.death()
		await get_tree().create_timer(6).timeout
		camera_3d.position = scare_position
		audio_stream_player.play()
		await get_tree().create_timer(2.3).timeout
		get_tree().quit()
