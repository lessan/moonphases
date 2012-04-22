MoonPhases
====================
A simple way to estimate the phase of the moon on any date in the past or future.  This parses the data made available by NASA at http://eclipse.gsfc.nasa.gov/phase/phasecat.html.
Note that this is for entertainment purposes only - I'm rounding times to the nearest day, and using linear interpolation where sinusoidal is clearly more appropriate.  If you use this for navigation, astronomy, astrology, or lycanthropy, you do so at your own risk.

Installation
------------
	gem install moonphases

Sample Usage
----------------------------
	toko:MoonPhases cmlacy$ irb
	>> require 'moonphases'
	=> true
	>> moon = MoonPhases.new
	=> #<MoonPhases:0x101380db8 @documentLog=[], @documentCache={}>
	>> moon.getMoonFullness( Date.new 2012, 4, 22 )
	=> #<Fullness:0x10161fb28 @direction="+", @percent=Rational(25, 4)>
	>> moon.getMoonFullness( Date.new 2012, 4, 21 )
	=> #<Fullness:0x1016067b8 @direction="+", @percent=0>
	>> moon.getMoonFullness( Date.new 2012, 4, 23 )
	=> #<Fullness:0x101594320 @direction="+", @percent=Rational(25, 2)>
	>> moon.getMoonFullness( Date.new 2012, 4, 24 )
	=> #<Fullness:0x101516f60 @direction="+", @percent=Rational(75, 4)>