extends Node3D

@onready var welcome: AudioStreamPlayer3D = $"../VoiceLines/Welcome"
@onready var coming_up: AudioStreamPlayer3D = $"../VoiceLines/ComingUp"
@onready var player: CharacterBody3D = $"../../../../Player"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
var food_position: Vector3 = Vector3(45.7, 3.14, -19.744)
@onready var food_collect: Node3D = $"../../FoodCollect"
@onready var pw_cheesecake_strawberry: Node3D = $"../../FoodCollect/PW_cheesecake_strawberry"
@onready var pw_croissant: Node3D = $"../../FoodCollect/PW_croissant"
@onready var pw_cookie: Node3D = $"../../FoodCollect/PW_cookie"
@onready var pw_cupcake_chocolattechips: Node3D = $"../../FoodCollect/PW_cupcake_chocolattechips"
@onready var pw_doughnut_pink: Node3D = $"../../FoodCollect/PW_doughnut_pink"
@onready var pw_frenchtoast_strawberry: Node3D = $"../../FoodCollect/PW_frenchtoast_strawberry"
@onready var enjoy: AudioStreamPlayer3D = $"../VoiceLines/Enjoy"
@onready var how_pay: AudioStreamPlayer3D = $"../VoiceLines/HowPay"
@onready var come_back_and_pay: AudioStreamPlayer3D = $"../VoiceLines/ComeBackAndPay"
@onready var oh_you_came_back: AudioStreamPlayer3D = $"../VoiceLines/OhYouCameBack"
@onready var thanks_for_paying: AudioStreamPlayer3D = $"../VoiceLines/ThanksForPaying"
@onready var not_enough: AudioStreamPlayer3D = $"../VoiceLines/NotEnough"

var can_interact: bool = true
var stolen_food: bool = false
var left_with_food: bool = false
var started_game: bool = false

func interact() -> void:
	if player.coins >= 0 and started_game:
		thanks_for_paying.play()
		Globals.on_day += 1
		Globals.coins = player.coins
		await thanks_for_paying.finished
		get_tree().change_scene_to_file("res://Scenes/World.tscn")
	
	if not can_interact and not welcome.playing and not animation_player.is_playing():
		not_enough.play()
		return
		
	can_interact = false
	welcome.play()
	player.stop_movement()

func _on_welcome_finished() -> void:
	player.show_purchases()

func steal() -> void:
	if enjoy.playing:
		enjoy.stop()
	if player.coins >= 20:
		for e in food_collect.get_children():
			e.visible = false
		food_collect.position = Vector3(0,-9000,0)
		player.modify_coins(-20)
		thanks_for_paying.play()
		Globals.on_day += 1
		Globals.coins = player.coins
		await thanks_for_paying.finished
		get_tree().change_scene_to_file("res://Scenes/World.tscn")

	how_pay.play()
	for e in food_collect.get_children():
		e.visible = false
	food_collect.position = Vector3(0,-9000,0)
	player.modify_coins(-20)
	started_game = true
	player.objective_find_coins()
	stolen_food = true

func purchase(item: String) -> void:
	coming_up.play()
	animation_player.play("Cook")
	await get_tree().create_timer(5.5).timeout
	animation_player.play_backwards("Cook")
	food_collect.position = food_position
	enjoy.play()
	match item:
		"DONUT":
			pw_doughnut_pink.visible = true
		"CUPCAKE":
			pw_cupcake_chocolattechips.visible = true
		"COOKIE":
			pw_cookie.visible = true
		"CHEESECAKE":
			pw_cheesecake_strawberry.visible = true
		"CROISSANT":
			pw_croissant.visible = true
		"JAM TOAST":
			pw_frenchtoast_strawberry.visible = true

func _on_thief_trigger_body_entered(body: Node3D) -> void:
	if body.name == "Player" and stolen_food:
		stolen_food = false
		come_back_and_pay.play()
		left_with_food = true
		await get_tree().create_timer(15).timeout
		left_with_food = false
		
func _on_thief_trigger_2_body_entered(body: Node3D) -> void:
	if body.name == "Player" and left_with_food:
		oh_you_came_back.play()
		left_with_food = false
