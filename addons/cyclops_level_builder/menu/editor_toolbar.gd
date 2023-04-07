# MIT License
#
# Copyright (c) 2023 Mark McKay
# https://github.com/blackears/cyclopsLevelBuilder
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends PanelContainer
class_name EditorToolbar

var editor_plugin:CyclopsLevelBuilder:
	get:
		return editor_plugin
	set(value):
		editor_plugin = value
		editor_plugin.active_node_changed.connect(on_active_node_changed)
#var editor_plugin:CyclopsLevelBuilder

func on_active_node_changed():
	update_grid()
	

#enum Tool { MOVE, DRAW, CLIP, VERTEX, EDGE, FACE }
#var tool:Tool = Tool.MOVE

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/grid_size.clear()
	$HBoxContainer/grid_size.add_item("1/16", 0)
	$HBoxContainer/grid_size.add_item("1/8", 1)
	$HBoxContainer/grid_size.add_item("1/4", 2)
	$HBoxContainer/grid_size.add_item("1/2", 3)
	$HBoxContainer/grid_size.add_item("1", 4)
	$HBoxContainer/grid_size.add_item("2", 5)
	$HBoxContainer/grid_size.add_item("4", 6)
	$HBoxContainer/grid_size.add_item("8", 7)
	$HBoxContainer/grid_size.add_item("16", 8)
	
	update_grid

func update_grid():
	if editor_plugin.active_node:
		var size:int = editor_plugin.active_node.grid_size
		$HBoxContainer/grid_size.select(size + 4)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grid_size_item_selected(index):
#	if Engine.is_editor_hint():
	print("_on_grid_size_item_selected " + str(index))

#	var iface:EditorInterface = editor_plugin.get_editor_interface()
#	var settings:EditorSettings = iface.get_editor_settings()
	
#	settings.set_setting("editors/3d/grid_size", index)
	
	if editor_plugin.active_node:
		editor_plugin.active_node.grid_size = index - 4


func _on_bn_move_pressed():
	editor_plugin.switch_to_tool(ToolBlock.new())


func _on_bn_clip_pressed():
	editor_plugin.switch_to_tool(ToolClip.new())


func _on_bn_vertex_pressed():
	editor_plugin.switch_to_tool(ToolEditVertex.new())


func _on_bn_edge_pressed():
	editor_plugin.switch_to_tool(ToolEditEdge.new())


func _on_bn_face_pressed():
	pass


func _on_check_lock_uvs_toggled(button_pressed):
	editor_plugin.lock_uvs = button_pressed


func _on_bn_prism_pressed():
	editor_plugin.switch_to_tool(ToolPrism.new())
