extends Node

const SAVE_PATH: String = "user://save.ini"

class Save:
	var map: PackedByteArray
	var player_target_cell: Vector2i
	var turn: int
	var score: int

	func _init() -> void:
		turn = GameManager.current_turn
		score = GameManager.get_score()
		player_target_cell = GameManager.instance.player._target_cell
		map = GameManager.instance.map.serialize_grid()
	
	func save_to_file(section: String) -> void:
		var config_file := ConfigFile.new()

		config_file.set_value(section, "map", map)
		config_file.set_value(section, "player_pos", player_target_cell)
		config_file.set_value(section, "turn", turn)
		config_file.set_value(section, "score", score)

		config_file.save(SAVE_PATH)

# Object Assignment
@export var map: Map
@export var player: Player

# Saves
var autosaves: Array[Save] = []
var manual_save: Save

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


# Save Systems
func autosave(_coord: Vector2i) -> void:
	var save: Save = Save.new()
	autosaves.append(save)
	save.save_to_file("Autosave")


func manually_save() -> void:
	manual_save = Save.new()
	manual_save.save_to_file("Manual")


func load_prev_autosave() -> void:
	if autosaves.size() > 1:
		var save: Save = autosaves.pop_back()
		load_save(save)
	elif autosaves.size() > 0:
		load_save(autosaves[0])


func load_manual_save() -> void:
	load_save(manual_save)


func load_save(save: Save):
	map.deserialize_grid(save.map)
	player.position = map.cell_coord_to_pos(save.player_target_cell)
	player._target_cell = save.player_target_cell
	GameManager.instance.current_turn = save.turn
	GameManager.instance.score = save.score


func get_save_from_file(section: String) -> Save:
	var config_file := ConfigFile.new()
	var error := config_file.load(SAVE_PATH)

	if error:
		print("An error happened while loading data: ", error)
		return
	
	var save := Save.new()
	save.map = config_file.get_value(section, "map", null)
	save.player_target_cell = config_file.get_value(section, "player_pos", Vector2i.ZERO)
	save.turn = config_file.get_value(section, "turn", 0)
	save.score = config_file.get_value(section, "score", 0)
	
	return save
