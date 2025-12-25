@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"SceneBuild", "Node3D",
		preload("res://addons/scenebuilder/Scripts/SceneBuild.gd"),
		preload("res://addons/scenebuilder/Icon16.png")
	)


func _exit_tree():
	remove_custom_type("SceneBuild")
