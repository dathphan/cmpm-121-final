class_name Map extends Node2D

@export var water_per_turn: Vector2 = Vector2(0, 1)
@export var sun_values: Vector2 = Vector2(1, 2)

@export var plant_datas: Array[PlantData]
@export var plant_prefab: PackedScene
@export var plant_container: Node2D

@export var tilled_tilemaps: Array[TileMapLayer]
@export var ground_tilemaps: Array[TileMapLayer]
@export var obstacle_tilemaps: Array[TileMapLayer]
var tilled_cells: Dictionary
var ground_cells: Dictionary
var plants: Array[Plant] = []

signal plant_status_changed(cell: Cell)

func _ready():
	initialize_cells()

# Assign cell dictionaries based on tilemaps
func initialize_cells() -> void:
	ground_cells = {}
	tilled_cells = {}
	var tilled_tiles := get_used_cells(tilled_tilemaps)
	var ground_tiles := get_used_cells(ground_tilemaps)
	var obstacle_tiles := get_used_cells(obstacle_tilemaps)
	
	for tile in ground_tiles:
		if obstacle_tiles.has(tile):
			continue
		if tilled_tiles.has(tile):
			tilled_cells[tile] = null
		ground_cells[tile] = Cell.new(tile) # Create a new Cell for this position


func give_cell_resources() -> void:
	for cell in ground_cells.values():
		cell.add_water(randf_range(water_per_turn.x, water_per_turn.y))
		cell.set_sun(randf_range(sun_values.x, sun_values.y))


func update_plants() -> void:
	for plant in plants:
		print(plant)
		plant.check_growth_conditions()


func remove_plant(plant: Plant) -> void:
	plants.erase(plant)
	plant.cell.set_plant(null)
	plant_status_changed.emit(plant.cell)
	plant.queue_free()


func clear_plants() -> void:
	var temp_plants: Array[Plant] = plants.duplicate()
	for plant in temp_plants:
		remove_plant(plant)


func new_turn(turn: int) -> void:
	give_cell_resources()
	update_plants()

func get_cell_from_coord(coord: Vector2i) -> Cell:
	return ground_cells.get(coord)

func get_cell_from_pos(position: Vector2) -> Cell:
	return ground_cells.get(pos_to_cell_coord(position))

func pos_to_cell_coord(position: Vector2) -> Vector2i:
	return ground_tilemaps[0].local_to_map(position)

func cell_coord_to_pos(coord: Vector2i) -> Vector2:
	return ground_tilemaps[0].map_to_local(coord) + Vector2(0.5, 0.5) # Adjust for tile center

func is_ground_cell(coord: Vector2i) -> bool:
	return ground_cells.has(coord)

# Push a plant to the map
func add_plant(plant: Plant) -> void:
	plants.append(plant)
	print("Plant %s has been planted" % plant.get_name())

func get_neighbors(position: Vector2i) -> Array[Vector2i]:
	return [
		position + Vector2i.UP,
		position + Vector2i.DOWN,
		position + Vector2i.LEFT,
		position + Vector2i.RIGHT
	]

func create_tile(coord: Vector2i) -> bool:
	return is_ground_cell(coord)

func get_used_cells(tilemaps: Array[TileMapLayer]) -> Array:
	# Using a dictionary to avoid duplicates
	var dict : Dictionary = {}
	for tilemap in tilemaps:
		for tile in tilemap.get_used_cells():
			if dict.has(tile): continue
			dict[tile] = null
	return dict.keys()


## Loading and Saving Functions:
const WATER_LVL_INDEX: int = 0
const SUN_LVL_INDEX: int = 2
const PLANT_TYPE_INDEX: int = 4
const PLANT_STAGE_INDEX: int = 5
const TOTAL_BYTES = 6

func serialize_grid() -> PackedByteArray:
	var byte_array: PackedByteArray = PackedByteArray()
	
	var index: int = 0
	
	for coord in ground_cells.keys():
		var cell: Cell = ground_cells[coord]
		
		# Ensure there's enough space before encoding
		if index + TOTAL_BYTES > byte_array.size():
			# Increase capacity if needed
			byte_array.resize(index + TOTAL_BYTES)
		
		byte_array.encode_half(index + WATER_LVL_INDEX, cell.water_level)
		byte_array.encode_half(index + SUN_LVL_INDEX, cell.sun_level)
		byte_array.encode_s8(index + PLANT_TYPE_INDEX, _get_plant_index(cell))
		byte_array.encode_s8(index + PLANT_STAGE_INDEX, _get_plant_stage(cell))
			
		index += TOTAL_BYTES

	return byte_array


func _get_plant_index(cell: Cell) -> int:
	if cell.plant == null: return 0
	
	var index = 1
	for data in plant_datas:
		if data == cell.plant.plant_data:
			return index
		index += 1
	return 0


func _get_plant_stage(cell: Cell) -> int:
	if cell.plant == null: return 0
	return cell.plant.current_stage


func deserialize_grid(data: PackedByteArray) -> void:
	clear_plants()
	
	var index: int = 0
	
	# Iterate over cell coordinates
	for coord in ground_cells.keys():
		var cell: Cell = ground_cells[coord]
		
		if index + TOTAL_BYTES > data.size():
			print("Insufficient data to read cell at index %d" % index)
			break  # Safety check for reading beyond the byte array

		# Deserialize water level (2 bytes)
		cell.water_level = data.decode_half(index + WATER_LVL_INDEX)
		
		# Deserialize sun level (2 bytes)
		cell.sun_level = data.decode_half(index + SUN_LVL_INDEX)
		
		# Deserialize plant type index (1 byte)
		var plant_type_index = data.decode_s8(index + PLANT_TYPE_INDEX)
		var plant_stage = data.decode_s8(index + PLANT_STAGE_INDEX)  # Deserialize plant stage (1 byte)
		
		# Create or set the plant if the index is valid (greater than 0)
		if plant_type_index > 0:
			var plant_data = plant_datas[plant_type_index - 1]
			create_plant_from_data(cell, plant_data, plant_stage)

		# Increment the index for the next cell
		index += TOTAL_BYTES


func create_random_plant(cell_coord: Vector2i) -> bool:
	var cell = get_cell_from_coord(cell_coord)
	var random_plant_data = plant_datas[randi() % plant_datas.size()]
	
	return create_plant_from_data(cell, random_plant_data, 0)


func create_plant_from_data(cell: Cell, plant_data: PlantData, stage: int) -> bool:
	if not tilled_cells.has(cell.coord) or cell.get_plant() != null:
		print("Cannot plant here! Either the cell is occupied or invalid.")
		return false
	
	var new_plant: Plant = plant_prefab.instantiate()
	new_plant.position = cell_coord_to_pos(cell.coord)
	plant_container.add_child(new_plant)
	new_plant.initialize(cell, self, plant_data)
	add_plant(new_plant)
	cell.set_plant(new_plant)
	plant_status_changed.emit(cell)
	
	return true
