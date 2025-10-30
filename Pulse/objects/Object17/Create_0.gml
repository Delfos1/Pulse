var _p = get_open_filename("particle.pulsep","particle.pulsep")
	
	if _p != ""
	{
		 _emitter = pulse_import_emitter(_p,true)	
			_emitter = pulse_store_emitter(_emitter,_emitter.name,false)
			
	}