extends Area2D

@onready var label := get_node("winText")
@onready var sound := get_node("AudioStreamPlayer2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.key_collected:
			body.game_won = true
			label.visible = true
			sound.play()
