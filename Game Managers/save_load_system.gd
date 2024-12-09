class_name SaveLoad extends Node

const SAVE_PATH: String = "user://save.ini"

class Save:
	var map: PackedByteArray
	var player_target_cell: Vector2i
	var turn: int
	var move_count: int
	var score: int

	func _init() -> void:
		turn = GameManager.current_turn
		score = GameManager.get_score()
		player_target_cell = Player.instance._target_cell
		map = GameManager.instance.map.serialize_grid()
		move_count = Player.instance.move_count
	
	func save_to_file(section: String) -> void:
		var config_file := ConfigFile.new()
		var error = config_file.load(SAVE_PATH)

		# Check for error while loading the existing file
		if error != OK:
			print("Failed to load configuration file: ", error)

		config_file.set_value(section, "map", map)
		config_file.set_value(section, "player_pos", player_target_cell)
		config_file.set_value(section, "turn", turn)
		config_file.set_value(section, "score", score)
		config_file.set_value(section, "move_count", move_count)

		config_file.save(SAVE_PATH)

# Object Assignment
@export var map: Map
@export var player: Player

# Saves
var autosaves: Array[Save] = []
var manual_save: Save

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


# Save Systems
func autosave(_turn: int) -> void:
	# Runs every turn
	var save: Save = Save.new()
	autosaves.append(save)
	save.save_to_file("Recover")


func manually_save() -> void:
	manual_save = Save.new()
	manual_save.save_to_file("Manual")
	print("Manual SAve")


func load_prev_autosave() -> void:
	print(autosaves.size())
	if autosaves.size() > 1:
		var save: Save = autosaves.pop_back()
		load_save(save)
	elif autosaves.size() > 0:
		load_save(autosaves[0])


func load_manual_save() -> void:
	load_save(get_save_from_file("Manual"))


func load_recover_save() -> void:
	load_save(get_save_from_file("Recover"))


func load_save(save: Save):
	map.deserialize_grid(save.map)
	player._target_pos = map.cell_coord_to_pos(save.player_target_cell)
	player.position = player._target_pos
	player._target_cell = save.player_target_cell
	player.move_count = save.move_count
	GameManager.instance.current_turn = save.turn
	GameManager.instance.score = save.score


func get_save_from_file(section: String) -> Save:
	var config_file := ConfigFile.new()
	var error := config_file.load(SAVE_PATH)

	if error:
		print("Save Load Error: ", error)
		return
	
	var save := Save.new()
	save.map = config_file.get_value(section, "map", null)
	save.player_target_cell = config_file.get_value(section, "player_pos", Vector2i.ZERO)
	save.turn = config_file.get_value(section, "turn", 0)
	save.score = config_file.get_value(section, "score", 0)
	save.move_count = config_file.get_value(section, "move_count", 0)
	
	return save
