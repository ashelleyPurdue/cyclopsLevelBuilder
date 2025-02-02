# Cyclops Level Builder Change Log


### v1.0.3
* The create shape tools now have an option for referencing the current active object to determine where in space they are drawn.
* Shape creation tools now let you specify collision settings.
* Right click cancel now does not undo rotation and move after operation has been completed.
* Now flushing snapping changes whenever a setting is changed.
* Renaming Settings to CyclopsSettings
* Now generating tangent vectors for block meshes.
* Restoring ability for UVs to remain in place when moving blocks.
* ~~Adding option to clear UV transform in material brush.~~
* Adding tool to export current scene as Godot scene with only native Godot objects.
* Overhaul of the material manager.  Will now automatically track all materials in project and provide filters to let you focus on subsets of materials.
* Can drag and drop Texture2D resources from the file explorer into the material directory window to automatically create new materials.  Dragging more than one texture will create an animated texture sequence.
* Adding command to merge vertices at center.
* Material brush can now apply UV coordinates
* Material brush can sample brush settings from under the cursor by pressing Shift-X
* Adding face-vertices to ConvexBlockData
* Creating vertex paint brush for painting face-vertices
* Fixing error where box selecting vertices, edges or faces sometimes caused a null pointer problem.

### v1.0.4
* You can now right-click fly when the vertex, edge or face tools are selected.
* Adding alignment option to primitive creation tools so that you can turn off the auto alignment to surfaces.
* ConvexVolume is now generating indexed meshes which should take up less memory and also allow occluders to be baked properly on exported scenes.

