require 'test/unit'
require 'moonphases'

class MoonPhasesTest < Test::Unit::TestCase
  def test_AD_Years
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0001.html", MoonPhases.lookupURL( 1 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0001.html", MoonPhases.lookupURL( 100 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0101.html", MoonPhases.lookupURL( 101 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0101.html", MoonPhases.lookupURL( 200 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0201.html", MoonPhases.lookupURL( 201 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0201.html", MoonPhases.lookupURL( 300 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0301.html", MoonPhases.lookupURL( 301 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0901.html", MoonPhases.lookupURL( 1000 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases1001.html", MoonPhases.lookupURL( 1001 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases2001.html", MoonPhases.lookupURL( 2012 )
  end
  
  def test_padding
    assert_equal "0001", MoonPhases.paddedString( 1 )
    assert_equal "0010", MoonPhases.paddedString( 10 )
    assert_equal "0100", MoonPhases.paddedString( 100 )
    assert_equal "1000", MoonPhases.paddedString( 1000 )
  end
end
