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
extends CyclopsTool
class_name ToolEditEdge

var handles:Array[HandleEdge] = []

enum ToolState { READY, DRAGGING }
var tool_state:ToolState = ToolState.READY

var drag_handle:HandleEdge
#var drag_mouse_start_pos:Vector2
var drag_handle_start_pos:Vector3
			
var tracked_blocks_root:CyclopsBlocks

var cmd_move_edge:CommandMoveEdge

func draw_tool():
	var global_scene:CyclopsGlobalScene = builder.get_node("/root/CyclopsAutoload")
	global_scene.clear_tool_mesh()
	
	var blocks_root:CyclopsBlocks = builder.active_node
	for h in handles:
		global_scene.draw_line(h.p0, h.p1)
#		var block:CyclopsConvexBlock = builder.get_node(h.block_path)
#		var ctl_mesh:ConvexVolume = block.control_mesh
#		var edge:ConvexVolume.EdgeInfo = ctl_mesh.edges[h.edge_index]
#		var p0:Vector3 = ctl_mesh.vertices[edge.start_index].point
#		var p1:Vector3 = ctl_mesh.vertices[edge.end_index].point
#		global_scene.draw_line(p0, p1)
	
func setup_tool():
	handles = []
	
	var blocks_root:CyclopsBlocks = builder.active_node
	if blocks_root == null:
		return
		
	for child in blocks_root.get_children():
		if child is CyclopsConvexBlock:
			var block:CyclopsConvexBlock = child
			if block.selected:
				for e_idx in block.control_mesh.edges.size():
					var ctl_mesh:ConvexVolume = block.control_mesh
					var e:ConvexVolume.EdgeInfo = ctl_mesh.edges[e_idx]

					var handle:HandleEdge = HandleEdge.new()
					handle.p0 = ctl_mesh.vertices[e.start_index].point
					handle.p0_init = handle.p0
					handle.p1 = ctl_mesh.vertices[e.end_index].point
					handle.p1_init = handle.p1
#					handle.cur_position = ctl_mesh.vertices[e.start_index].point
#					handle.start_position = handle.p0
					handle.edge_index = e_idx
					handle.block_path = block.get_path()
					handles.append(handle)
					
					
					#print("adding handle %s" % handle)


func pick_closest_handle(blocks_root:CyclopsBlocks, viewport_camera:Camera3D, position:Vector2, radius:float)->HandleEdge:
	var best_dist:float = INF
	var best_handle:HandleEdge = null
	
	var pick_origin:Vector3 = viewport_camera.project_ray_origin(position)
	var pick_dir:Vector3 = viewport_camera.project_ray_normal(position)
	
	for h in handles:
		var block:CyclopsConvexBlock = builder.get_node(h.block_path)
		var ctl_mesh:ConvexVolume = block.control_mesh
		var edge:ConvexVolume.EdgeInfo = ctl_mesh.edges[h.edge_index]
#		var p0:Vector3 = h.p0
#		var p1:Vector3 = ctl_mesh.vertices[edge.end_index].point
		
		var p0_world:Vector3 = blocks_root.global_transform * h.p0
		var p1_world:Vector3 = blocks_root.global_transform * h.p1
		
		var p0_screen:Vector2 = viewport_camera.unproject_position(p0_world)
		var p1_screen:Vector2 = viewport_camera.unproject_position(p1_world)
		
		var dist_to_seg_2d_sq = MathUtil.dist_to_segment_squared_2d(position, p0_screen, p1_screen)
		
		if dist_to_seg_2d_sq > radius * radius:
			#Failed handle radius test
			continue

		var point_on_seg:Vector3 = MathUtil.closest_point_on_segment(pick_origin, pick_dir, p0_world, p1_world)
		
		var offset:Vector3 = point_on_seg - pick_origin
		var parallel:Vector3 = offset.project(pick_dir)
		var dist = parallel.dot(pick_dir)
		if dist <= 0:
			#Behind camera
			continue
		
		#print("h pos %s ray orig %s ray dir %s offset %s para %s dist %s perp %s" % [h.position, ray_origin, ray_dir, offset, parallel, dist, perp])
		if dist >= best_dist:
			continue
		
		best_dist = dist
		best_handle = h

	return best_handle

func active_node_changed():
	if tracked_blocks_root != null:
		tracked_blocks_root.blocks_changed.disconnect(active_node_updated)
		tracked_blocks_root = null
		
	setup_tool()
	draw_tool()
	
	tracked_blocks_root = builder.active_node
	if tracked_blocks_root:
		tracked_blocks_root.blocks_changed.connect(active_node_updated)
		
	

func active_node_updated():
	setup_tool()
	draw_tool()

func _activate(builder:CyclopsLevelBuilder):
	super._activate(builder)
	
	builder.active_node_changed.connect(active_node_changed)
	
	tracked_blocks_root = builder.active_node
	if tracked_blocks_root:
		tracked_blocks_root.blocks_changed.connect(active_node_updated)
	
	
	setup_tool()
	draw_tool()
	
	
func _deactivate():
	super._deactivate()
	builder.active_node_changed.disconnect(active_node_changed)
	if tracked_blocks_root != null:
		tracked_blocks_root.blocks_changed.disconnect(active_node_updated)


#func get_handle_start_point(handle:HandleEdge)->Vector3:
#	var block:CyclopsConvexBlock = builder.get_node(handle.block_path)
#	var vol:ConvexVolume = block.control_mesh
#	var edge:ConvexVolume.EdgeInfo = vol.edges[handle.edge_index]
#	return vol.vertices[edge.start_index].point

func _gui_input(viewport_camera:Camera3D, event:InputEvent)->bool:	
	var blocks_root:CyclopsBlocks = self.builder.active_node
	var grid_step_size:float = pow(2, blocks_root.grid_size)
	var global_scene:CyclopsGlobalScene = builder.get_node("/root/CyclopsAutoload")

#	if event is InputEventKey:
#		return true

	if event is InputEventMouseButton:
		
		var e:InputEventMouseButton = event
		if e.button_index == MOUSE_BUTTON_LEFT:

			if e.is_pressed():
				
				if tool_state == ToolState.READY:
					var handle:HandleEdge = pick_closest_handle(blocks_root, viewport_camera, e.position, builder.handle_screen_radius)
					
					#print("picked handle %s" % handle)
					if handle:
						drag_handle = handle
#						drag_mouse_start_pos = e.position
#						drag_handle_start_pos = handle.position
						tool_state = ToolState.DRAGGING

						drag_handle_start_pos = handle.p0_init

						cmd_move_edge = CommandMoveEdge.new()
						cmd_move_edge.builder = builder
						cmd_move_edge.block_path = handle.block_path
						cmd_move_edge.edge_index = handle.edge_index
#						cmd_move_edge.drag_start_position = handle.initial_position
#						cmd_move_edge.vertex_position = handle.initial_position
						
				return true
			else:
				if tool_state == ToolState.DRAGGING:
					#Finish drag
					var undo:EditorUndoRedoManager = builder.get_undo_redo()

					cmd_move_edge.add_to_undo_manager(undo)
									
					tool_state = ToolState.READY
					setup_tool()

	elif event is InputEventMouseMotion:
		var e:InputEventMouseMotion = event

		if (e.button_mask & MOUSE_BUTTON_MASK_MIDDLE):
			return false		
			
		if tool_state == ToolState.DRAGGING:

			var origin:Vector3 = viewport_camera.project_ray_origin(e.position)
			var dir:Vector3 = viewport_camera.project_ray_normal(e.position)

			var start_pos:Vector3 = origin + builder.block_create_distance * dir
			var w2l = blocks_root.global_transform.inverse()
			var origin_local:Vector3 = w2l * origin
			var dir_local:Vector3 = w2l.basis * dir
			
			var drag_to:Vector3
			if e.alt_pressed:
				drag_to = MathUtil.closest_point_on_line(origin_local, dir_local, drag_handle_start_pos, Vector3.UP)
			else:
				drag_to = MathUtil.intersect_plane(origin_local, dir_local, drag_handle_start_pos, Vector3.UP)
			
			drag_to = MathUtil.snap_to_grid(drag_to, grid_step_size)
			
			var offset = drag_to - drag_handle.p0_init
			drag_handle.p0 = drag_handle.p0_init + offset
			drag_handle.p1 = drag_handle.p1_init + offset
			
			cmd_move_edge.move_offset = offset
			cmd_move_edge.do_it()

			draw_tool()
			return true
		
	return false

