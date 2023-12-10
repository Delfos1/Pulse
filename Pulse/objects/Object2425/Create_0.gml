// Input variables
 circleCenterX = x;
 circleCenterY = y
 radius = 100

 
 startPointX = mouse_x
 startPointY = mouse_y
 angle =180
 
 // Convert angle to radians if it's in degrees
var angleInRadians = degtorad(angle);




// Calculate the coordinates of the endpoints of the chord
endPointX = circleCenterX + radius * dcos(angle);
endPointY = circleCenterY + radius * dsin(angle);
endPointX2 = circleCenterX + radius * dcos(angle);
endPointY2 = circleCenterY + radius * dsin(angle);
// Calculate the length of the chord using the distance formula
_length_to_edge = point_distance(startPointX, startPointY, endPointX, endPointY);
