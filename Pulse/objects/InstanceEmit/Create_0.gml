// This is how to emit INSTANCES instead of particles. The instances will be created at the
// system's layer or depth. If the system has a layer, it will take a preference.
// Setting a system's depth will erase the layer's reference. Setting a layer will
// add the layer's depth to the system's depth variable.
//For example, you could add a system to a layer and then do
//system.set_depth()
//And that would create the instances at the same depth but not on the same layer 

particle = pulse_make_instance_particle(o_particle_example,"particle")
system	= pulse_make_system("system",false,"Instances_1")


emit = new pulse_emitter("system","particle",20)


emit.boundary=PULSE_BOUNDARY.NONE
particle.set_speed(1,2).set_life(30,50).set_gravity(270,.2)


