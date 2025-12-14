// feather ignore all

/// @func LookoutInstances()
/// @param {Bool} startVisible? Whether the debug view starts visible (true) or not (false). [Default: true]
/// 
/// @desc Displays the overall and per-object instance counts in a "Lookout: Instances" debug view, including differences between frames, with an option to destroy objects.
/// Helps track existing objects and their instance counts to identify objects that are out of place.
/// 
/// Call this function once at the start of the game.
function LookoutInstances(_startVisible = true) {
	static __ = new (function(_startVisible) constructor {
		__objects = array_map(asset_get_ids(asset_object), function(_obj) {
			return {
				__ref: _obj,
				__name: object_get_name(_obj),
				__n: 0,
				__nPrev: 0,
				__nDelta: 0,
				__died: false,
				__display: undefined,
			};
		});
		__totalInstances = undefined;
		__LookoutCreateView("Lookout: Instances", _startVisible, 420, 500);
		__section = undefined;
		
		__Refresh = function() {
			__totalInstances = instance_count;
			array_foreach(__objects, function(_obj) {
				with (_obj) {
					__n = instance_number(__ref);
					if (__n != __nPrev) {
					    __nDelta = __n - __nPrev;
					}
					__nPrev = __n;
				}
			});
			array_sort(__objects, function(_a, _b) {
				var _diff = sign(_b.__n - _a.__n);
				return ((_diff != 0) ? _diff : ((_b.__name > _a.__name) ? -1 : +1));
			});
			
			if (__section != undefined) {
				dbg_section_delete(__section);
			}
			dbg_set_view(__view);
			__section = dbg_section($"Total: {instance_count}");
			
			array_foreach(__objects, function(_obj) {
				with (_obj) {
					if (__n > 0) {
						__display = __n;
						if (__nDelta != 0) {
							__display = $"{__display} ({(__nDelta > 0) ? "+" : "-"}{abs(__nDelta)})";
						}
						dbg_watch(ref_create(_obj, "__display"), _obj.__name);
						if (__n > 0) {
							dbg_same_line();
							dbg_button("Destroy", function() {
								instance_destroy(__ref);
							}, 60, 19);
						}
					}
				}
			});
		};
		
		__Refresh();
		call_later(1, time_source_units_frames, function() {
			if (not is_debug_overlay_open()) return;
			if (instance_count == __totalInstances) return;
			
			__Refresh();
		}, true);
	})(_startVisible);
}
