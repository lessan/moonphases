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

  def test_BC_Years
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", MoonPhases.lookupURL( 0 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", MoonPhases.lookupURL( -1 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", MoonPhases.lookupURL( -99 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0199.html", MoonPhases.lookupURL( -100 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0199.html", MoonPhases.lookupURL( -199 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0299.html", MoonPhases.lookupURL( -200 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0999.html", MoonPhases.lookupURL( -900 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0999.html", MoonPhases.lookupURL( -999 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-1099.html", MoonPhases.lookupURL( -1000 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-1099.html", MoonPhases.lookupURL( -1099 )
  end
  
  def test_padding
    assert_equal "0001", MoonPhases.paddedString( 1 )
    assert_equal "0010", MoonPhases.paddedString( 10 )
    assert_equal "0100", MoonPhases.paddedString( 100 )
    assert_equal "1000", MoonPhases.paddedString( 1000 )
  end
  
  def test_get_data
    assert_raise OpenURI::HTTPError do
      MoonPhases.getNASADoc( 50000 )
    end
    
    assert_nothing_raised OpenURI::HTTPError do
      MoonPhases.getNASADoc( 2012 )
    end
    
    doc = MoonPhases.getNASADoc 2012
    assert_equal "NASA - Moon Phases:  2001 to  2100", doc.title
  end
end
