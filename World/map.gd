class_name Map extends Node2D

@export var water_per_turn: Vector2 = Vector2(0, 1)
@export var sun_values: Vector2 = Vector2(1, 2)

@export var tilled_tilemaps: Array[TileMapLayer]
@export var ground_tilemaps: Array[TileMapLayer]
@export var obstacle_tilemaps: Array[TileMapLayer]
var tilled_cells: Dictionary
var ground_cells: Dictionary
var plants: Array[Plant] = []

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
