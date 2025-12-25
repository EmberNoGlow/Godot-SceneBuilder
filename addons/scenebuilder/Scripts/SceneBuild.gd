@tool
@icon("res://addons/scenebuilder/Icon16.png")
extends Node3D
class_name SceneBuilder

@export_tool_button("Build", "MeshInstance3D") var b = build
## Selecting the Standart point scatter function.[br]
## [color=yellow]Warning:[/color] If "Custom" is selected, "CustomFunctionName" must not be an empty string
@export_enum("Circle", "Grid", "Custom") var FunctionName : String = "Circle":
	set(value):
		FunctionName = value
		if value == "Grid":
			set("DontPassSpiralArgs", true)
		else:
			set("DontPassSpiralArgs", false)

## Custom Scatter Function It should be at ScatterFunctions.gd![br]
## [color=yellow]Warning:[/color] To use it, set the FunctionName to "Custom"!
@export var CustomFunctionName : StringName = ""
@export var InstanceAmount: int = 8
@export var Atan2InstanceRotation : bool = true
@export var DistanceFromCenter: float = 1.0
@export var InstanceRotation: Vector3 = Vector3.ZERO
@export var InstanceRotationAxis: Vector3 = Vector3.UP
@export var SourceMesh: Mesh
@export var DontPassSpiralArgs : bool = false ## If your function does not accept arguments for the spiral, check this box!

@export var Spiral: bool = false
@export var SpiralHeight: float = 1.0
@export var SpiralTurns: float = 1.0
@export var SpiralRadiusGrowth: float = 0.0 


## Write the arguments for your custom function separated by commas:
## [codeblock]
## - `true, 2.0, 1.0` → [true, 2.0, 1.0]
## - `"text", 42` → ["text", 42]
## - Empty String → [] (without args)
## [/codeblock]
## The values should be passed to a function that accepts "...args" and accessed through an array index:[br]
## [br]
## [color=white] in ScatterFunctions.gd: [/color]
## [codeblock]
## static func my_points_scatter(
##		# Standart args
##		amount: int, distance_to_center: float, 
##		
##		# Spiral ARGS (if DontPassSpiralArgs is FALSE)
##		Spiral = false, SpiralHeight = 1.0, SpiralTurns = 1.0, SpiralRadiusGrowth = 0.0, 
##		
##		# ADDITIONAL ARGS:
##		...args
##) -> Array:
## [/codeblock]
## For more info see Docs!
@export var CustomArgs : String 


@export_group("Material")
@export var material: BaseMaterial3D

const SceneBuilderData = preload("res://addons/scenebuilder/Scripts/SceneBuilderData.gd")
const CustomMesh = SceneBuilderData.CustomMesh
const ScatterFunctions = preload("res://addons/scenebuilder/Scripts/ScatterFunctions.gd")

const PointsFunction = {
	"Circle" : Callable(ScatterFunctions, "create_circle_points"),
	"Grid" : Callable(ScatterFunctions, "create_grid_points")
}


func build():
	SceneBuilderData.clear_children(self)
	var fn = PointsFunction.get(FunctionName) if FunctionName != "Custom" \
	else Callable(ScatterFunctions, CustomFunctionName)
	
	var args = [
		SourceMesh, 
		fn,
		InstanceRotation, 
		InstanceRotationAxis,
		Atan2InstanceRotation,
		material,
		InstanceAmount, 
		DistanceFromCenter
	]

	if !DontPassSpiralArgs:
		args.append_array([Spiral, SpiralHeight, SpiralTurns, SpiralRadiusGrowth])
	
	args.append_array(parse_custom_args(CustomArgs))
	#print(args)

	var inst = SceneBuilderData.new().callv("create_inst", args)
	
	if inst:
		add_child(inst)

func _ready():
	build()


static func parse_custom_args(args_str: String) -> Array:
	if args_str.strip_edges() == "":
		return []
	var args = args_str.split(",")
	var parsed_args = []
	for arg in args:
		var trimmed = arg.strip_edges()
		if trimmed.is_valid_float():
			parsed_args.append(float(trimmed))
		elif trimmed.to_lower() in ["true", "false"]:
			parsed_args.append(trimmed.to_lower() == "true")
		else:
			parsed_args.append(trimmed)
	return parsed_args
