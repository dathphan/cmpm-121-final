class_name Cell

var water_level: float = 0
var sun_level: float = 0
var plant: Plant
var coord: Vector2i

func _init(coordinates: Vector2i) -> void:
	coord = coordinates

func get_water() -> float:
	return water_level

func get_sun() -> float:
	return sun_level

func get_plant() -> Plant:
	return plant

func add_water(value: float) -> void:
	water_level += value

func set_sun(value: float) -> void:
	sun_level = value

func set_plant(plant: Plant) -> void:
	self.plant = plant

func _to_string() -> String:
	return "Water: %s\nSun: %s" % [water_level, sun_level]
