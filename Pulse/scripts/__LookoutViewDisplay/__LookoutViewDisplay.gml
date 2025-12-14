// feather ignore all

function __LookoutDisplayParam(_name, _value, _setter) {
	if ((_value != self[$ _name]) and (_value != self[$ $"{_name}Prev"])) {
		self[$ _name] = _value;
		self[$ $"{_name}Prev"] = _value;
	}
	else if (self[$ _name] != self[$ $"{_name}Prev"]) {
		_setter(self[$ _name]);
		self[$ $"{_name}Prev"] = self[$ _name];
	}
}
function __LookoutDisplayGetWH(_w, _h) {
	return $"{_w}x{_h}";
}
function __LookoutDisplayGetWHAR(_w, _h) {
	return $"{_w}x{_h}: {_w / _h}";
}
