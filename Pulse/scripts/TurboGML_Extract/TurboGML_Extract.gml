//Extract from TurboGML
/* Feel free to download the entire library and remove this script. Its worth it!


/*--------------------------------------------------------------------------------------------
	TurboGML. A complete library with must-have functionality.
	- Library by FoxyOfJungle (Mozart Junior). (C) 2023, MIT License.
	
	It would mean a lot to me to have my name in your project/game credits! :D
	Don't remove this notice, please :)
	
	https://foxyofjungle.itch.io/
	https://twitter.com/foxyofjungle
	
	..............................
	Special Thanks, contributions:
	YellowAfterLife, Cecil, TheSnidr, Xot, Shaun Spalding, gnysek, icuurd12b42, DragoniteSpam.
	(authors' names written in comment inside the functions used)
	
	Supporters:
	RookTKO
---------------------------------------------------------------------------------------------*/

/*
	MIT License
	
	Copyright (c) 2022 Mozart Junior (FoxyOfJungle)
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/
// Feather ignore all



/// @desc This function works like clamp(), but if the value is greater than max, it becomes min, and vice versa.
/// @param {Real} val The value to check.
/// @param {Real} minn The min value.
/// @param {Real} maxx The max value.
function clamp_wrap(val, minn, maxx) {
	if (val > maxx) val = minn; else if (val < minn) val = maxx;
	return val;
}

/// @desc Works like a lerp() but for angles, no rotation limits.
/// @param {Real} a The first angle to check.
/// @param {Real} b The second angle to check.
/// @param {Real} amount The amount to interpolate.
/// @returns {Real} 
function lerp_angle(a, b, amount) {
	var _a = a + angle_difference(b, a);
	return lerp(a, _a, amount);
	//return a - (angle_difference(a, b) * _amount);
}
