
// dynamically changing the gravity strength to make a wavey back and forth effect
acc += add
if  abs(acc)>1 add = -add ;

particle.set_gravity(acc*.0045,0)

emit.pulse(1,0,0)