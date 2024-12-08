class_name PlantData extends Resource

# Register the resource type for editing in the editor
# You can register it in the Godot Editor's EditorSettings too
@export var plant_name: String
@export var min_water: float
@export var min_sun: float
@export var preferred_neighbor_plants: Array[String]
@export var plant_sprites: Rect2i
