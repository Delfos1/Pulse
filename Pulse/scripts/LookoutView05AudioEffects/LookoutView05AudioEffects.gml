// feather ignore all

/// @func LookoutAudioEffects()
/// @param {Bool} startVisible? Whether the debug view starts visible (true) or not (false). [Default: true]
///
/// @desc Provides controls for all 8 audio effects on audio_bus_main in a "Lookout: Audio Effects" debug view.
/// Includes type selection and parameter tweaking.
///
/// Call this function once at the start of the game.
function LookoutAudioEffects(_startVisible = true) {
	static __ = new (function(_startVisible) constructor {
		__Refresh = function() {
			dbg_set_view(__view);
			array_foreach(__effects, function(_effect) {
				_effect.__Refresh();
			});
		};
		
		call_later(1, time_source_units_frames, function() {
			if (not is_debug_overlay_open()) return;
			
			__Refresh();
		}, true);
		
		__LookoutCreateView("Lookout: Audio Effects", _startVisible, 420, 500);
		dbg_section("Master"); {
			var _w = 130;
			var _h = 19;
			dbg_button("Remove All", function() {
				array_foreach(audio_bus_main.effects, function(_effect, _i) {
					delete audio_bus_main.effects[_i];
				});
			}, _w, _h);
			dbg_same_line();
			dbg_button("Bypass All", function() {
				array_foreach(audio_bus_main.effects, function(_effect) {
					with (_effect) {
						bypass = true;
					}
				});
			}, _w, _h);
			dbg_same_line();
			dbg_button("Unbypass All", function() {
				array_foreach(audio_bus_main.effects, function(_effect) {
					with (_effect) {
						bypass = false;
					}
				});
			}, _w, _h);
		}
		__effects = array_create_ext(8, function(_i) {
			return new __LookoutAudioEffect(_i);
		});
		__Refresh();
	})(_startVisible);
}
