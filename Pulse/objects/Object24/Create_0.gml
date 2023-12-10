// Given data
function LineCircleIntersect(_cx, _cy, _r, _x1, _y1, _x2, _y2)
{
    // Find intersect points with a line and a circle
    // Circle origin [_cx, _cy] with radius _r
    // Line of [_x1, _y1] to [_x2, _y2]
    
    #macro M_EPS (math_get_epsilon())
    
    _cx = _x1 - _cx;
    _cy = _y1 - _cy;
    
    var _vx  = _x2 - _x1, 
        _vy  = _y2 - _y1, 
        _a   = _vx * _vx + _vy * _vy,
        _b   = 2 * (_vx * _cx + _vy * _cy),
        _c   = _cx * _cx + _cy * _cy - _r * _r,
        _det = _b * _b - 4 * _a * _c;
    
    if (_a <= M_EPS || _det < 0)
    {
        // No real solutions.
        return noone;
    }
    else if (_det == 0)
    {
        // Line is tangent to the circle
        var _t = -_b / (2 * _a);
        var _p1 = { X : _x1 + _t * _vx, Y : _y1 + _t * _vy };
        return [_p1, _p1];
    }
    else
    {
        // Line intersects circle
        _det = sqrt(_det);
        var _t1 = (-_b - _det) / (2 * _a);
        var _t2 = (-_b + _det) / (2 * _a);
        
        // First point is closest to [_x1, _y1]
        return [{ X : _x1 + _t1 * _vx, Y : _y1 + _t1 * _vy }, 
                { X : _x1 + _t2 * _vx, Y : _y1 + _t2 * _vy }];
    }
}

circle_x = x /* center x-coordinate of the circle */;
circle_y = y /* center y-coordinate of the circle */;
circle_radius = 100 /* radius of the circle */;

line_x0 = x+10 /* starting x-coordinate of the line */;
line_y0 = y+10/* starting y-coordinate of the line */;
line_angle = 45/* angle of the line in degrees */;
line_length = 200

line_x1=lengthdir_x(line_length, line_angle)+line_x0
line_y1 =lengthdir_y(line_length, line_angle)+line_y0

intersections = LineCircleIntersect(circle_x,circle_y,circle_radius,line_x0,line_y0,line_x1,line_y1)

if intersections != noone
intersect = true







