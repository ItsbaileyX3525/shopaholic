extends Node3D
@onready var redroom: Node3D = $"../redroom"
@onready var camera_3d: Camera3D = $"../redroom/Camera3D"
@onready var player: CharacterBody3D = $"../../Player"
@onready var audio_stream_player: AudioStreamPlayer = $"../redroom/jumpscare"
@onready var whynopay: AudioStreamPlayer = $"../redroom/whynopay"

var items_available: int = 0
var default_position: Vector3 = Vector3(-2.648,-34.903,31.403)
var scare_position: Vector3 = Vector3(-2.748,-32.957,-1.134)

func _ready() -> void:
	for e in get_children():
		items_available += 1

func check_interactables() -> void:
	items_available -= 1
	if items_available <= 0:
		if player.coins >= 0:
			print("Player had enough+")
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
