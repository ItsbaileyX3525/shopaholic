extends Control

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_options_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit(0)
