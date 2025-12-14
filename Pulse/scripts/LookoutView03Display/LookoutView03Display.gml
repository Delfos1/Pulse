// feather ignore all

/// @func LookoutDisplay()
/// @param {Bool} startVisible? Whether the debug view starts visible (true) or not (false). [Default: true]
/// 
/// @desc Provides info and controls for display, window, application surface, and views in a "Lookout: Display" debug view.
/// Inspired by Pixelated Pope's display_write_all_specs().
/// 
/// Call this function once at the start of the game.
function LookoutDisplay(_startVisible = true) {
	static __ = new (function(_startVisible) constructor {
		__display = {
			__size: undefined,
			// ar, guiW, guiH, guiAR appSurfW, appSurfH, appSurfAR, timingMethod, sleepMargin
			__orientation: undefined,
			__frequency: undefined,
			__dpi: undefined,
		};
		__window = {}; // x, y, w, h, ar, fullscreen, border, cursor, caption
		__views = array_create_ext(8, function(_i) {
			return {
				__i: _i,
				__cam: view_camera[_i],
				// x, y, w, h, ar, visible
			};
		});
		__Refresh = function() {
			with (__display) {
				__size = $"{display_get_width()}x{display_get_height()}";
				__ar = display_get_width() / display_get_height();
				__LookoutDisplayParam("__guiW", display_get_gui_width(), function(_w) {
					display_set_gui_size(_w, display_get_gui_height());
				});
				__LookoutDisplayParam("__guiH", display_get_gui_height(), function(_h) {
					display_set_gui_size(display_get_gui_width(), _h);
				});
				__guiAR = display_get_gui_width() / display_get_gui_height();
				__LookoutDisplayParam("__appSurfW", surface_get_width(application_surface), function(_w) {
					display_set_gui_size(_w, surface_get_height(application_surface));
				});
				__LookoutDisplayParam("__appSurfH", surface_get_height(application_surface), function(_h) {
					display_set_gui_size(surface_get_width(application_surface), _h);
				});
				__appSurfAR = surface_get_width(application_surface) / surface_get_height(application_surface);
				
				switch (display_get_orientation()) {
					case display_landscape: __orientation = "Landscape"; break;
					case display_landscape_flipped: __orientation = "Landscape Flipped"; break;
					case display_portrait: __orientation = "Portrait"; break;
					case display_portrait_flipped: __orientation = "Portrait Flipped"; break;
				};
				__frequency = $"{display_get_frequency()}hz";
				__dpi = __LookoutDisplayGetWH(display_get_dpi_x(), display_get_dpi_y());
				
				__LookoutDisplayParam("__timingMethod", display_get_timing_method(), display_set_timing_method)
				__LookoutDisplayParam("__sleepMargin", display_get_sleep_margin(), display_set_sleep_margin)
			}
			with (__window) {
				__LookoutDisplayParam("__x", window_get_x(), function(_x) {
					window_set_position(_x, window_get_y());
				});
				__LookoutDisplayParam("__y", window_get_y(), function(_y) {
					window_set_position(window_get_x(), _y);
				});
				__LookoutDisplayParam("__w", window_get_width(), function(_w) {
					window_set_size(clamp(_w, 500, display_get_width()), window_get_height());
				});
				__LookoutDisplayParam("__h", window_get_height(), function(_h) {
					window_set_size(window_get_width(), clamp(_h, 500, display_get_height()));
				});
				__ar = window_get_width() / window_get_height();
				__LookoutDisplayParam("__fullscreen", window_get_fullscreen(), window_set_fullscreen)
				__LookoutDisplayParam("__border", window_get_showborder(), window_set_showborder)
				__LookoutDisplayParam("__cursor", window_get_cursor(), window_set_cursor);
				__LookoutDisplayParam("__caption", window_get_caption(), window_set_caption);
			}
			array_foreach(__views, function(_view, _i) {
				with (_view) {
					__LookoutDisplayParam("__visible", view_visible[_i], function(_visible) {
						view_visible[__i] = _visible;
					});
					__LookoutDisplayParam("__x", camera_get_view_x(__cam), function(_x) {
						camera_set_view_pos(__cam, _x, camera_get_view_y(__cam));
					});
					__LookoutDisplayParam("__y", camera_get_view_y(__cam), function(_y) {
						camera_set_view_pos(__cam, camera_get_view_x(__cam), _y);
					});
					__LookoutDisplayParam("__w", camera_get_view_width(__cam), function(_w) {
						camera_set_view_size(__cam, _w, camera_get_view_height(__cam));
					});
					__LookoutDisplayParam("__h", camera_get_view_height(__cam), function(_h) {
						camera_set_view_pos(__cam, camera_get_view_width(__cam), _h);
					});
					__ar = camera_get_view_width(__cam) / camera_get_view_width(__cam);
					__port = $"Pos: {view_get_xport(_i)},{view_get_yport(_i)}. Size: {view_get_wport(_i)}x{view_get_hport(_i)}"
				}
			});
		};
		
		__LookoutCreateView("Lookout: Display", _startVisible, 420, 675);
		
		var __Half = function(_getterX, _getterY, _setter) {
			dbg_same_line();
			with ({_getterX, _getterY, _setter}) {
				dbg_button("/2", function() {
					_setter(_getterX() / 2, _getterY() / 2);
				}, 20, 19);
			}
		}
		var __Double = function(_getterX, _getterY, _setter) {
			dbg_same_line();
			with ({_getterX, _getterY, _setter}) {
				dbg_button("x2", function() {
					_setter(_getterX() * 2, _getterY() * 2);
				}, 20, 19);
			}
		}
		
		// display
		dbg_section("Display", true);
		dbg_watch(ref_create(__display, "__size"), "Size");
		dbg_watch(ref_create(__display, "__ar"), "Aspect Ratio");
		
		dbg_text_separator("GUI", 1);
		dbg_text_input(ref_create(__display, "__guiW"), "Width", "i"); __Half(display_get_gui_width, display_get_gui_height, display_set_gui_size);
		dbg_text_input(ref_create(__display, "__guiH"), "Height", "i"); __Double(display_get_gui_width, display_get_gui_height, display_set_gui_size);
		dbg_watch(ref_create(__display, "__guiAR"), "Aspect Ratio");
		
		dbg_text_separator("Application Surface", 1);
		var _GetAppSurfW = function() { return surface_get_width(application_surface); };
		var _GetAppSurfH = function() { return surface_get_height(application_surface); };
		var _ResizeAppsurf = function(_w, _h) { surface_resize(application_surface, _w, _h); };
		dbg_text_input(ref_create(__display, "__appSurfW"), "Width", "i"); __Half(_GetAppSurfW, _GetAppSurfH, _ResizeAppsurf);
		dbg_text_input(ref_create(__display, "__appSurfH"), "Height", "i"); __Double(_GetAppSurfW, _GetAppSurfH, _ResizeAppsurf);
		dbg_watch(ref_create(__display, "__appSurfAR"), "Aspect Ratio");
		
		dbg_text_separator("Extras", 1);
		dbg_watch(ref_create(__display, "__orientation"), "Orientation");
		dbg_watch(ref_create(__display, "__frequency"), "Frequency");
		dbg_watch(ref_create(__display, "__dpi"), "DPI");
		
		static _timingMethods = [tm_sleep, tm_countvsyncs, tm_countvsyncs_winalt, tm_systemtiming];
		static _timingMethodNames = ["Sleep", "Count VSyncs", "Count Vsyncs Winalt", "System Timing"];
		dbg_drop_down(ref_create(__display, "__timingMethod"), _timingMethods, _timingMethodNames, "Timing Method");
		dbg_slider_int(ref_create(__display, "__sleepMargin"), 0, 20, "Sleep Margin");
		
		// window
		dbg_section("Window", true);
		dbg_text_input(ref_create(__window, "__x"), "X", "i");
		dbg_same_line();
		dbg_button("Center", function() {
			window_set_position((display_get_width() - window_get_width()) / 2, window_get_y());
		}, 50, 19);
		dbg_text_input(ref_create(__window, "__y"), "Y", "i");
		dbg_same_line();
		dbg_button("Center", function() {
			window_set_position(window_get_x(), (display_get_height() - window_get_height()) / 2);
		}, 50, 19);
		dbg_text_input(ref_create(__window, "__w"), "Width", "i");
		dbg_text_input(ref_create(__window, "__h"), "Height", "i");
		dbg_watch(ref_create(__window, "__ar"), "Aspect Ratio");
		dbg_text_separator("");
		dbg_checkbox(ref_create(__window, "__fullscreen"), "Fullscreen");
		dbg_checkbox(ref_create(__window, "__border"), "Border");
		
		{static _cursors = [
			cr_none,
			cr_default,
			cr_arrow,
			cr_cross,
			cr_beam,
			cr_size_nesw,
			cr_size_ns,
			cr_size_nwse,
			cr_size_we,
			cr_uparrow,
			cr_hourglass,
			cr_appstart,
			cr_handpoint,
			cr_size_all,
		];}
		{static _cursorNames = [
		    "None",
		    "Default",
		    "Arrow",
		    "Cross",
		    "Beam",
		    "Size NESW",
		    "Size NS",
		    "Size NWSE",
		    "Size WE",
		    "Up Arrow",
		    "Hourglass",
		    "App Start",
		    "Hand Point",
		    "Size All"
		];}
		dbg_drop_down(ref_create(__window, "__cursor"), _cursors, _cursorNames, "Cursor");
		dbg_text_input(ref_create(__window, "__caption"), "Caption");
		
		// views
		array_foreach(__views, function(_view, _i) {
			with (_view) {
				dbg_section($"View {_i}", false);
				dbg_checkbox(ref_create(_view, "__visible"), "Visible");
				dbg_text_input(ref_create(_view, "__x"), "X", "i");
				dbg_text_input(ref_create(_view, "__y"), "Y", "i");
				dbg_text_input(ref_create(_view, "__w"), "Width", "i");
				dbg_text_input(ref_create(_view, "__w"), "Height", "i");
				dbg_watch(ref_create(_view, "__ar"), "Aspect Ratio");
				dbg_watch(ref_create(_view, "__port"), "Port");
			}
		});
		
		__Refresh();
		call_later(1, time_source_units_frames, __Refresh, true);
	})(_startVisible);
}
