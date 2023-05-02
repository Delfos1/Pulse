/// @func   gauss(m, sd)
///
/// @desc   Returns a pseudo-random number with an exact Gaussian distribution.
///
/// @param  {real}      m           mean value of the distribution
/// @param  {real}      sd          standard deviation of distribution
///
/// @return {real}      random number with Gaussian distribution
///
/// GMLscripts.com/license
#region License 
/*
 Copyright (c) 2007-2022, GMLscripts.com

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.

  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.

  3. This notice may not be removed or altered from any source distribution.

GMLscripts.com/license
*/
#endregion

function gauss(m, sd)
{
    var x1, x2, w;
    do {
        x1 = random(2) - 1;
        x2 = random(2) - 1;
        w = x1 * x1 + x2 * x2;
    } until (0 < w && w < 1);
 
    w = sqrt(-2 * ln(w) / w);
    return m + sd * x1 * w;
}