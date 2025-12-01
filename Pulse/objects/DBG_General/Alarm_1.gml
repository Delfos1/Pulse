/// @description Load from Included Files

	var _p = "emitter_slug.pulsee"
	
	if _p != ""
	{
		var temp_emitter = pulse_import_emitter(_p,false),	
			_emitter = pulse_store_emitter(temp_emitter,temp_emitter.name,false)
			temp_emitter.destroy()
		var _check = false,_sys,_part
		
		
		with DBG_System
		{
			if system == _emitter.part_system
			{
				_check = true	
				_sys = id
			}
		}
		
		if !_check
		{
			var _inst_s		= instance_create_layer(0,0,layer,DBG_System,{system: _emitter.part_system})
					array_push(systems,_inst_s)
					s_l = array_length(systems)-1
					_sys = _inst_s
		}
		
		_check = false
		with DBG_Particle
		{
			if particle == _emitter.part_type
			{
				_check = true	
				_part = id
			}
		}
		
		if  !_check
		{
			var	_inst_p = instance_create_layer(0,0,layer,DBG_Particle,{particle: _emitter.part_type})
				array_push(particles,_inst_p)
				p_l = array_length(particles)-1
				_part = _inst_p
		}
		instance_create_layer(random_range(1300,1600),random_range(300,600),layer,DBG_Emitter,{emitter: _emitter, system_instance: _sys , particle_instance : _part})
		array_push(emitters,_emitter)
	}