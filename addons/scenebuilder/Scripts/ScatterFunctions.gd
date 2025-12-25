@tool

static func create_circle_points(
	amount: int, distance_to_center: float, # Standart args
	Spiral = false, SpiralHeight = 1.0, SpiralTurns = 1.0, SpiralRadiusGrowth = 0.0, # CUSTOM ARGS
	...args # "Safety lock" - if too many arguments are passed to a function, it will not cause an error
) -> Array:
	var points = []
	var angle_step = 2 * PI * SpiralTurns / amount if Spiral else 2 * PI / amount
	for i in range(amount):
		var angle = i * angle_step
		var radius = distance_to_center + (i * SpiralRadiusGrowth / amount)
		var x = radius * cos(angle)
		var y = i * SpiralHeight / amount if Spiral else 0.0
		var z = radius * sin(angle)
		points.append(Vector3(x, y, z))
	return points


static func create_grid_points(
	amount: int, distance_to_center: float, # Standart args
	GridSizeX: float = 1.0, GridSizeZ: float = 1.0, GridSegments = 1, # CUSTOM ARGS
	...args # "Safety lock"
) -> Array:
	var points = []

	var segments = GridSegments
	if segments < 1:
		segments = int(sqrt(amount))
		if segments < 1:
			segments = 1
			
	var points_per_side = segments 
	
	var half_width_x = distance_to_center
	var half_width_z = distance_to_center
	
	var step_x = (half_width_x * 2.0) / (points_per_side - 1) if points_per_side > 1 else 0.0
	var step_z = (half_width_z * 2.0) / (points_per_side - 1) if points_per_side > 1 else 0.0
	
	var start_x = -half_width_x
	var start_z = -half_width_z
	
	for i in range(points_per_side):
		var x = start_x + i * step_x
		
		for j in range(points_per_side):
			var z = start_z + j * step_z
			
			var y = 0.0 
			
			
			points.append(Vector3(x, y, z))
			
	return points
