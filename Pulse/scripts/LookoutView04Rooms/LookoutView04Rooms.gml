// feather ignore all

/// @func LookoutRooms()
/// @param {Bool} startVisible? Whether the debug view starts visible (true) or not (false). [Default: true]
/// 
/// @desc Provides control over room switching and displays room history in a "Lookout: Rooms" debug view.
/// Useful for quickly switching between rooms for testing, and identifying unintentional room changes.
///
/// Call this function once at the start of the game.
function LookoutRooms(_startVisible = true) {
	static __ = new(function(_startVisible) constructor {
		__rooms = asset_get_ids(asset_room);
		__names = array_map(__rooms, function(_room, _index) {
			return $"{_index}: {room_get_name(_room)}";
		});
		__n = array_length(__rooms);
		__prevRoom = room;
		__room = room;
		__size = undefined;
		__history = {
			__n: 16,
			__pool: undefined,
			
			__Init: function() {
				dbg_section("History");
				__pool = array_create(__n, "-");
				__Add(room);
				for (var _i = 0; _i < __n; _i++) {
					var _ii = _i + 1;
					var _label = ((_ii < 10) ? $"0{_ii}" : _ii)
					dbg_watch(ref_create(self, "__pool", _i), _label);
				}
			},
			__Add: function(_room) {
				array_insert(__pool, 0, room_get_name(_room));
				if (array_length(__pool) > __n) {
					array_pop(__pool);
				}
			},
		};
		__GoTo = function(_room) {
			room_goto(_room);
			__room = _room;
			__prevRoom = __room;
			__history.__Add(_room);
		};
		
		__LookoutCreateView("Lookout: Rooms", _startVisible, 420, 414);
		dbg_section("Control");
		dbg_drop_down(ref_create(self, "__room"), __rooms, __names, "Room");
		
		var _size = 19;
		dbg_same_line();
		dbg_button("-", function() {
			var _index = array_get_index(__rooms, room) - 1;
			if (_index == -1) _index = __n - 1;
			
			__GoTo(__rooms[_index]);
		}, _size, _size);
		dbg_same_line();
		dbg_button("+", function() {
			var _index = array_get_index(__rooms, room) + 1;
			if (_index == __n) _index = 0;
			
			__GoTo(__rooms[_index]);
		}, _size, _size);
		
		var _w = 127;
		dbg_watch(ref_create(self, "__size"), "Size");
		dbg_button("Restart", function() { __GoTo(room); }, _w, _size);
		dbg_same_line();
		dbg_button("First", function() { __GoTo(room_first); }, _w - 1, _size);
		dbg_same_line();
		dbg_button("Last", function() { __GoTo(room_last); }, _w - 1, _size);
		
		__history.__Init();
		
		call_later(1, time_source_units_frames, function() {
			if (__prevRoom != room) {
				__room = room;
				__prevRoom = __room;
				__history.__Add(room);
			}
			if (__room != __prevRoom) {
				__GoTo(__room);
			}
			__size = $"{room_width}x{room_height}";
		}, true);
	})(_startVisible);
}
