// feather ignore all

function __LookoutAudioEffect(_index) constructor {
	static __types = array_concat([undefined], __LookoutGetAudioEffectTypes());
	static __n = array_length(__types);
	
	__index = _index;
	__section = undefined;
	__type = undefined;
	__prevType = undefined;
	__effect = undefined;
	__initialized = false;
	__controls = [];
	
	static __Control = function(_control) {
		array_push(__controls, _control);
	};
	static __Mix = function() {
		__Control(dbg_slider(ref_create(__effect, "mix"), 0, 1, "Mix"));
	};
	static __Quality = function() {
		__Control(dbg_slider_int(ref_create(__effect, "q"), 1, 100, "Quality"));
	};
	static __Gain = function() {
		__Control(dbg_slider(ref_create(__effect, "gain"), 0, 3, "Gain", 0.05));
	};
	static __Frequency = function() {
		__Control(dbg_text_input(ref_create(__effect, "freq"), "Frequency", "r"));
	};
	
	static __Change = function(_dir) {
		var _baseIndex = (__effect == undefined) ? 0 : array_get_index(__types, __effect.type);
		var _newIndex = __LookoutMod2(_baseIndex + _dir, __n);
		
		__type = __types[_newIndex];
		__effect = (is_undefined(__type) ? undefined : audio_effect_create(__type));
		audio_bus_main.effects[__index] = __effect;
	};
	static __Refresh = function() {
		var _remoteEffect = audio_bus_main.effects[__index];
		var _remoteType = (is_undefined(_remoteEffect) ? undefined : _remoteEffect.type);
		var _tookRemote = false;
		
		if (_remoteEffect != __effect) {
			__effect = _remoteEffect;
			__type = (is_undefined(__effect) ? undefined : __effect.type);
			__prevType = __type;
			_tookRemote = true;
		}
		else if ((__initialized) and (__type == __prevType)) return;
		
		if (__initialized) {
			array_foreach(__controls, function(_control) {
				dbg_control_delete(_control);
			});
			__controls = [];
			dbg_set_section(__section);
		}
		else {
			__section = dbg_section($"Effect {__index}", (__index == 0));
		}
		__initialized = true;
		
		if (_tookRemote) {
			__effect = _remoteEffect;
		}
		else {
			__prevType = __type;
			__effect = (is_undefined(__type) ? undefined : audio_effect_create(__type));
			audio_bus_main.effects[__index] = __effect;
		}
		
		{static _names = [
			"None",
			"Reverb1",
			"Delay",
			"Bitcrusher",
			"LPF2",
			"HPF2",
			"Gain",
			"Tremolo",
			"EQ",
			"PeakEQ",
			"HiShelf",
			"LoShelf",
			"Compressor",
		];}
		__Control(dbg_drop_down(ref_create(self, "__type"), __types, _names, "Effect"));
		__Control(dbg_same_line());
		__Control(dbg_button("-", function() { __Change(-1); }, 19, 19));
		__Control(dbg_same_line());
		__Control(dbg_button("+", function() { __Change(+1); }, 19, 19));
		
		if (__effect == undefined) return;
		
		__Control(dbg_checkbox(ref_create(__effect, "bypass"), "Bypass"));
		
		switch (__effect.type) {
			case AudioEffectType.Reverb1: {
				__Control(dbg_slider(ref_create(__effect, "size"), 0, 1, "Size"));
				__Control(dbg_slider(ref_create(__effect, "damp"), 0, 1, "Damp"));
				__Mix();
				break;
			}
			case AudioEffectType.Delay: {
				__Control(dbg_slider(ref_create(__effect, "time"), 0, 3, "Time (seconds)", 0.1));
				__Control(dbg_slider(ref_create(__effect, "feedback"), 0, 1, "Feedback"));
				__Mix();
				break;
			}
			case AudioEffectType.Bitcrusher: {
				__Gain();
				__Control(dbg_slider_int(ref_create(__effect, "factor"), 0, 100, "Factor"));
				__Control(dbg_slider_int(ref_create(__effect, "resolution"), 0, 16, "Resolution"));
				__Mix();
				break;
			}
			case AudioEffectType.LPF2: {
				__Control(dbg_text_input(ref_create(__effect, "cutoff"), "Cutoff", "r"));
				__Quality();
				break;
			}
			case AudioEffectType.HPF2: {
				__Control(dbg_text_input(ref_create(__effect, "cutoff"), "Cutoff", "r"));
				__Quality();
				break;
			}
			case AudioEffectType.Gain: {
				__Gain();
				break;
			}
			case AudioEffectType.Tremolo: {
				static _shapes = [AudioLFOType.Sine, AudioLFOType.Square, AudioLFOType.Triangle, AudioLFOType.Sawtooth, AudioLFOType.InvSawtooth];
				static _shapeNames = ["Sine", "Square", "Triangle", "Sawtooth", "InvSawtooth"];
				
				__Control(dbg_slider(ref_create(__effect, "rate"), 0, 20, "Rate", 0.5));
				__Control(dbg_slider(ref_create(__effect, "intensity"), 0, 1, "Intensity"));
				__Control(dbg_slider(ref_create(__effect, "offset"), 0, 1, "Offset"));
				__Control(dbg_drop_down(ref_create(__effect, "shape"), _shapes, _shapeNames, "Shape"));
				break;
			}
			case AudioEffectType.EQ: {
				__Control(dbg_text(" Coming Soon..."));
				break;
			}
			case AudioEffectType.PeakEQ:
			case AudioEffectType.HiShelf:
			case AudioEffectType.LoShelf: {
				__Frequency();
				__Quality();
				__Gain();
				break;
			}
			case AudioEffectType.Compressor: {
				__Control(dbg_slider(ref_create(__effect, "ingain"), 0, 3, "In Gain", 0.05));
				__Control(dbg_slider(ref_create(__effect, "threshold"), 0.001, 1, "Threshold"));
				__Control(dbg_text_input(ref_create(__effect, "ratio"), "Ratio", "r"));
				__Control(dbg_slider(ref_create(__effect, "attack"), 0.001, 1, "Attack"));
				__Control(dbg_slider(ref_create(__effect, "release"), 0.001, 0.1, "Release"));
				__Control(dbg_slider(ref_create(__effect, "outgain"), 0, 3, "Out Gain", 0.05));
				break;
			}
		}
	};
}

function __LookoutGetAudioEffectTypes() {
	static _types = [
		AudioEffectType.Reverb1,
		AudioEffectType.Delay,
		AudioEffectType.Bitcrusher,
		AudioEffectType.LPF2,
		AudioEffectType.HPF2,
		AudioEffectType.Gain,
		AudioEffectType.Tremolo,
		AudioEffectType.EQ,
		AudioEffectType.PeakEQ,
		AudioEffectType.HiShelf,
		AudioEffectType.LoShelf,
		AudioEffectType.Compressor,
	];
	return _types;
}
