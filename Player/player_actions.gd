extends Node

# Object Assignment
@onready var player: Player = $".."
@export var plant_prefab: PackedScene
@export var plant_datas: Array[PlantData]
@export var plant_container: Node2D

# Private Variables
var map: Map
var _target_cell: Vector2i
signal plant_status_changed(cell: Cell)
	# UI Manager: update_current_cell()

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
	
	var cell = map.get_cell_from_coord(_target_cell)
	if map.tilled_cells.has(_target_cell) and cell.get_plant() == null:
		var new_plant: Plant = plant_prefab.instantiate()
		new_plant.position = map.cell_coord_to_pos(_target_cell)
		plant_container.add_child(new_plant)
		
		var random_plant_data = plant_datas[randi() % plant_datas.size()] # Random plant type selection
		new_plant.initialize(cell, map, random_plant_data)
		map.add_plant(new_plant)
		cell.set_plant(new_plant)
		plant_status_changed.emit(cell)
	else:
		print("Cannot plant here! Either the cell is occupied or invalid.")


func sow_at_current_cell():
	update_vars()
	
	var cell = map.get_cell_from_coord(_target_cell)
	if map.tilled_cells.has(_target_cell) and cell.get_plant() != null:
		var plant = cell.get_plant()
		if plant.is_fully_grown():
			GameManager.add_score(1)
			map.plants.erase(plant)
			cell.set_plant(null)
			plant.queue_free()
			plant_status_changed.emit(cell)
			print("Sowed %s. Score: %d" % [plant.get_name(), GameManager.get_score()])
		else:
			print("Plant is not fully grown yet!")
	else:
		print("No plant to sow here!")

func update_vars():
	self.map = player.map
	self._target_cell = player._target_cell
