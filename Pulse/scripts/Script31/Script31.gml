/// @func debug_resources()
/// @desc Displays the data fetched from debug_event("ResourceCounts") in a neat Resource Counts debug overlay view.
/// Call anywhere in the project.
function debug_resources() {
	static __ = new (function() constructor {
		var _refresh = function() {
			if (not is_debug_overlay_open()) return;
			struct_foreach(debug_event("ResourceCounts", true), function(_key, _value) {
				self[$ _key] = _value;
			});
		};
		_refresh();
		call_later(1, time_source_units_frames, _refresh, true);
		
		dbg_view("Resource Counts", true, 16, 35, 320, 500);
		dbg_text_separator("Resources");
		dbg_watch(ref_create(self, "listCount"), "DS Lists");
		dbg_watch(ref_create(self, "mapCount"), "DS Maps");
		dbg_watch(ref_create(self, "queueCount"), "DS Queues");
		dbg_watch(ref_create(self, "gridCount"), "DS Grids");
		dbg_watch(ref_create(self, "priorityCount"), "DS Priority Queues");
		dbg_watch(ref_create(self, "stackCount"), "DS Stacks");
		dbg_watch(ref_create(self, "mpGridCount"), "DS Grids");
		dbg_watch(ref_create(self, "bufferCount"), "Buffers");
		dbg_watch(ref_create(self, "vertexBufferCount"), "Vertex Buffers");
		dbg_watch(ref_create(self, "surfaceCount"), "Surfaces");
		dbg_watch(ref_create(self, "audioEmitterCount"), "Audio Emitters");
		dbg_watch(ref_create(self, "partSystemCount"), "Particle Systems");
		dbg_watch(ref_create(self, "partEmitterCount"), "Particle Emitters");
		dbg_watch(ref_create(self, "partTypeCount"), "Particle Types");
		dbg_watch(ref_create(self, "timeSourceCount"), "Time Sources");
		dbg_text_separator("Assets");
		dbg_watch(ref_create(self, "spriteCount"), "Sprites");		
		dbg_watch(ref_create(self, "pathCount"), "Paths");
		dbg_watch(ref_create(self, "fontCount"), "Fonts");
		dbg_watch(ref_create(self, "roomCount"), "Rooms");
		dbg_watch(ref_create(self, "timelineCount"), "Timelines");
		dbg_text_separator("Instances");					
		dbg_watch(ref_create(self, "instanceCount"), "Instances");
	})();
}