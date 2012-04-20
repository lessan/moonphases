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
      doc = MoonPhases.getNASADoc 2012
      assert_equal "NASA - Moon Phases:  2001 to  2100", doc.title
    end
  end
  
  def test_parse_year_blobs
      doc = MoonPhases.getNASADoc 2012
      assert_not_nil MoonPhases.findYearIn doc, 2012
      assert_nil MoonPhases.findYearIn doc, 1999    

      # Some AD Years      
      assert_equal 2015, (MoonPhases.getNASAYearBlob 2015).content[/-?\d+/].to_i
      assert_equal 9, (MoonPhases.getNASAYearBlob 9).content[/-?\d+/].to_i
      assert_equal 567, (MoonPhases.getNASAYearBlob 567).content[/-?\d+/].to_i
      assert_equal 1620, (MoonPhases.getNASAYearBlob 1620).content[/-?\d+/].to_i
      
      # OOH!  Year 0!
      assert_equal 0, (MoonPhases.getNASAYearBlob 0).content[/-?\d+/].to_i
      
      # How about some BC Years?
      assert_equal -1, (MoonPhases.getNASAYearBlob -1).content[/-?\d+/].to_i
      assert_equal -980, (MoonPhases.getNASAYearBlob -980).content[/-?\d+/].to_i
      assert_equal -38, (MoonPhases.getNASAYearBlob -38).content[/-?\d+/].to_i
      
      # These are the earliest and latest years for which NASA publishes data.
      assert_equal -1999, (MoonPhases.getNASAYearBlob -1999).content[/-?\d+/].to_i
      assert_equal 4000, (MoonPhases.getNASAYearBlob 4000).content[/-?\d+/].to_i

  end
end
