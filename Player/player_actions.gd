extends Node

# Object Assignment
@onready var player: Player = $".."

# Private Variables
var map: Map
var _target_cell: Vector2i

signal action_performed(Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_inputs()
	pass


func handle_inputs():
	# Planting mechanic (using "P" key for planting)
	if Input.is_action_just_pressed("plant"):
		plant_at_current_cell()
	# Sowing mechanic (using "O" key for sowing)
	if Input.is_action_just_pressed("sow"):
		sow_at_current_cell()


func plant_at_current_cell():
	update_vars()
	if map.create_random_plant(_target_cell):
		action_performed.emit(map.get_cell_from_coord(_target_cell))


func sow_at_current_cell():
	update_vars()
	
	var cell = map.get_cell_from_coord(_target_cell)
	if map.tilled_cells.has(_target_cell) and cell.get_plant() != null:
		var plant = cell.get_plant()
		if plant.is_fully_grown():
			GameManager.add_score(1)
			map.remove_plant(plant)
			action_performed.emit(map.get_cell_from_coord(_target_cell))
			print("Sowed %s. Score: %d" % [plant.get_name(), GameManager.get_score()])
		else:
			print("Plant is not fully grown yet!")
	else:
		print("No plant to sow here!")


func update_vars():
	self.map = player.map
	self._target_cell = player._target_cell
