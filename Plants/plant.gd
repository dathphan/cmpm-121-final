class_name Plant extends Node2D

@export var plant_data: PlantData

var current_stage: int = 0
var cell: Cell
var map: Map

const GROWTH_STAGES = 3 # Every plant has same number of growth stages


# This function initializes the plant with necessary parameters
func initialize(cell: Cell, map: Map, plant_data: PlantData) -> void:
	self.cell = cell
	current_stage = 0
	self.map = map
	self.plant_data = plant_data
	name = plant_data.plant_name
	update_plant_visual()


# Check if neighbors are valid for this plant
func check_valid_neighbors() -> bool:
	var plant_position: Vector2i = cell.coord
	var neighbors: Array[Vector2i] = map.get_neighbors(plant_position)
	for neighbor in neighbors: # For each adjacent plant
		if map.is_ground_cell(neighbor):
			var neighbor_cell: Cell = map.get_cell_from_coord(neighbor)
			var neighbor_plant: Plant = neighbor_cell.get_plant()
			if neighbor_plant != null:
				# Check if neighboring plant is part of the valid neighbor list
				if not plant_data.preferred_neighbor_plants.has(neighbor_plant.plant_data.plant_name):
					return false
	return true # All neighbors are either empty or valid


# Check the growth conditions for the plant
func check_growth_conditions() -> void:
	var water: float = cell.get_water()
	var sun: float = cell.get_sun()
	print(water, sun)
	if water >= plant_data.min_water and sun >= plant_data.min_sun and check_valid_neighbors():
		grow()


func grow() -> void:
	if current_stage < GROWTH_STAGES:
		current_stage += 1
		update_plant_visual()


# Check if the plant is fully grown
func is_fully_grown() -> bool:
	return current_stage == GROWTH_STAGES


# Update the visual representation of the plant
func update_plant_visual() -> void:
	print("%s grew to stage %d." % [get_name(), current_stage]) # testing
	print(plant_data.plant_sprites)
	$Sprite2D.region_rect = plant_data.plant_sprites
	$Sprite2D.frame = current_stage


func get_plant_name() -> StringName:
	return plant_data.plant_name
