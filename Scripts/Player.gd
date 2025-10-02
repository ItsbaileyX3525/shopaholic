extends CharacterBody3D

@export var speed: float = 5.0
@export var crouch_speed: float = 2.5
@export var jump_force: float = 6.0
@export var gravity: float = 15.0
@export var crouch_height: float = 1.0
@export var standing_height: float = 2.0
@export var mouse_sensitivity: float = 0.2
@export var max_look_angle: float = 85.0
@onready var interact: RayCast3D = %interact
@onready var interact_label: MarginContainer = $CanvasLayer/Crosshair/InteractLabel
@onready var purchase: Control = $CanvasLayer/Purchase
@onready var coin_counter: Label = $CanvasLayer/CoinCounter
@onready var objective_text: Label = $CanvasLayer/ObjectiveText
@onready var wheel: HBoxContainer = $CanvasLayer/Packs/WheelContainer/Wheel
@onready var wheel_container: Panel = $CanvasLayer/Packs/WheelContainer

var is_crouching: bool = false
var pitch: float = 0.0
var can_move: bool = true
var coins: int = 0
var last_interacted_with

@onready var camera: Camera3D = $Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D

const click_sound = preload("res://CoffeeShopStarterPack/UI/click.mp3")
const coin_texture = preload("res://CoffeeShopStarterPack/UI/coin.png")
const SPECIAL_COLOUR    = Color(18.892, 16.779, 1.637, 1.0)
const COVERT_COLOUR     = Color(18.188, 6.919, 6.919, 1.0)
const CLASSIFIED_COLOUR = Color(16.498, 4.736, 17.836, 1.0)
const RESTRICTED_COLOUR = Color(11.215, 6.638, 18.892, 1.0)
const MILSPEC_COLOUR    = Color(6.919, 9.032, 18.892, 1.0)

var rarities = [
	"Mil-Spec",
	"Restricted",
	"Classified",
	"Covert",
	"Special Item"
]
var weights = [
	7992, # 79.92%
	1598, # 15.98%
	320,  # 3.20%
	64,   # 0.64%
	26    # 0.26%
]

var rarities_relation: Dictionary = {
	"Mil-Spec" : MILSPEC_COLOUR,
	"Restricted" : RESTRICTED_COLOUR,
	"Classified" : CLASSIFIED_COLOUR,
	"Covert" : COVERT_COLOUR,
	"Special Item" : SPECIAL_COLOUR
}

var index = 0;

#ChatGPT generated function
func pick_weighted(items: Array, weighted_array: Array) -> Variant:
	if items.size() != weighted_array.size():
		push_error("Items and weights must be the same length")
		return null

	var total_weight = 0
	for w in weighted_array:
		total_weight += w
	
	var rnd = randi() % total_weight
	var cumulative = 0

	for i in range(items.size()):
		cumulative += weighted_array[i]
		if rnd < cumulative:
			return items[i]
	
	return items.back()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().create_timer(.2).timeout
	open_pack()

func stop_movement() -> void:
	can_move = false

func start_movement() -> void:
	can_move = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -max_look_angle, max_look_angle)
		camera.rotation_degrees.x = pitch

func spin_to_item(target_index: int):
	var item_width: float = wheel.get_child(0).size.x
	var spacing: float = wheel.get_theme_constant("separation")
	var center_x: float = wheel_container.size.x / 2
	var item_stride: float = item_width + spacing
	
	var target_item_center = target_index * item_stride + item_width / 2
	var final_x = center_x - target_item_center
	
	var extra_items = randi_range(50, 100)
	var start_x = final_x + (extra_items * item_stride)
	
	wheel.position.x = start_x
	
	# Track last item that passed center for sound
	var last_item_passed = -1
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(wheel, "position:x", final_x, 7.0)
	
	# Monitor position during tween to play click sounds
	while tween.is_running():
		await get_tree().create_timer(0.02).timeout
		var current_x = wheel.position.x
		# Calculate which item is currently at center
		var item_at_center = int((center_x - current_x) / item_stride)
		
		if item_at_center != last_item_passed and item_at_center >= 0 and item_at_center < wheel.get_child_count():
			last_item_passed = item_at_center
			# Create new audio instance for each click
			var audio = AudioStreamPlayer.new()
			audio.stream = click_sound
			add_child(audio)
			audio.play()
			# Auto-destroy after sound finishes
			audio.finished.connect(func(): audio.queue_free())
			print("Item passing center: ", wheel.get_child(item_at_center).name)

func populate_pack() -> void:
	for e in range(300):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(80,80)
		var rarity = pick_weighted(rarities, weights)
		var colour = rarities_relation[rarity]
		panel.name = "%s-%s" % [index, rarity]
		index += 1
		panel.self_modulate = colour
		
		var img = TextureRect.new()
		img.texture = coin_texture
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		panel.add_child(img)
		wheel.add_child(panel)
		img.size = Vector2(80,80)

func open_pack() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	can_move = false
	populate_pack()
	var spinTo = randi_range(170,280)
	# Wait a frame for children to be properly added
	await get_tree().process_frame
	spin_to_item(spinTo)
	index = 0
	print("Target item: ", wheel.get_child(spinTo).name)
	print("TextureRect: ", wheel.get_child(spinTo).get_child(0).name)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	if interact.is_colliding():
		var target = interact.get_collider()
		var split = target.name.split("-")
		if target.has_method("interact"):
			interact_label.visible = true
			if Input.is_action_just_pressed("interact"):
				target.interact()
				last_interacted_with = target
		
		elif split[0] == "coins" and split[1] == "none":
			interact_label.visible = true
			if Input.is_action_just_pressed("interact"):
				split[1] = "used"
				target.name = "coins-%s" % split[1]
				open_pack()
	else:
		interact_label.visible = false

	if not can_move:
		return

	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		if is_crouching:
			velocity.x = direction.x * crouch_speed
			velocity.z = direction.z * crouch_speed
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_force

	if Input.is_action_pressed("crouch") and is_on_floor():
		is_crouching = true
	else:
		is_crouching = false

	if collider and collider.shape is CapsuleShape3D:
		var capsule := collider.shape as CapsuleShape3D
		var target_height := crouch_height if is_crouching else standing_height
		capsule.height = lerp(capsule.height, target_height, delta * 10.0)

	move_and_slide()

func modify_coins(amount: int) -> void:
	coins += amount
	coin_counter.text = "COINS: %s" % coins

func show_purchases() -> void:
	purchase.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_purchases() -> void:
	purchase.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	can_move = true

func _on_cupcake_pressed() -> void:
	last_interacted_with.purchase("CUPCAKE")
	hide_purchases()

func _on_croissant_pressed() -> void:
	last_interacted_with.purchase("CROISSANT")
	hide_purchases()

func _on_cookie_pressed() -> void:
	last_interacted_with.purchase("COOKIE")
	hide_purchases()

func _on_cheesecake_pressed() -> void:
	last_interacted_with.purchase("CHEESECAKE")
	hide_purchases()

func _on_donit_pressed() -> void:
	last_interacted_with.purchase("DONUT")
	hide_purchases()

func _on_jam_toast_pressed() -> void:
	last_interacted_with.purchase("JAM TOAST")
	hide_purchases()

func objective_find_coins() -> void:
	objective_text.text = "OBJECTIVE:\nFind some coins to pay for your food.\nHINT: Check bins and barrels."
