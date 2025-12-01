function	_pulse_clamp_wrap(val, minn, maxx) {
	val = val - floor((val-minn)/(maxx-minn))*(maxx-minn)
	return val;
}