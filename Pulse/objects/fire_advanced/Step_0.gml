t2 = (t2 + increment2) % 360;
shift2 = amplitude2 * dsin(t2);
//---
t = (t + increment) % 360;
shift =( amplitude +(shift2)) * dsin(t);
//---

if emit_smaller.displacement_map == undefined exit


particle.set_orient(90,90,shift*.05,0,false).set_size(.5,.7,(-0.01+abs(shift2*.0005)))
sparks.set_direction(0,0,mean(shift,shift2)*random_range(.05,.1))

emit.set_focal_point(80+shift*.8,-500)
emit_smaller.set_focal_point(80+shift*.8,-150)

emit_smaller.displacement_map.set_offset(xx,yy);
emit.displacement_map.set_offset(xx,yy);
xx+=.005;
yy+=.015;

emit.pulse(15+(abs(shift2)*.2),x-80,y)
emit_smaller.pulse(30,x-80,y)
emit_spark.pulse(1,x,y-100)