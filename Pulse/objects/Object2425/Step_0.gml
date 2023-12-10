var angleInRadians = degtorad(angle+90);

// Calculate the length of the chord
// Calculate the coordinates of the endpoints of the chord


endPointX = circleCenterX +(  radius * sin(angleInRadians));
endPointY = circleCenterY +( radius * cos(angleInRadians));
startPointX = circleCenterX -( radius * sin(angleInRadians));
startPointY = circleCenterY -( radius * cos(angleInRadians));


// Calculate the length of the chord using the distance formula
_length_to_edge = point_distance(startPointX, startPointY, endPointX, endPointY);