require 'test/unit'
require 'moonphases'
require 'date'

class MoonPhasesTest < Test::Unit::TestCase
  def test_AD_Years
    moon = MoonPhases.new
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0001.html", moon.lookupURL( 1 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0001.html", moon.lookupURL( 100 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0101.html", moon.lookupURL( 101 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0101.html", moon.lookupURL( 200 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0201.html", moon.lookupURL( 201 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0201.html", moon.lookupURL( 300 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0301.html", moon.lookupURL( 301 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0901.html", moon.lookupURL( 1000 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases1001.html", moon.lookupURL( 1001 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases2001.html", moon.lookupURL( 2012 )
  end

  def test_BC_Years
    moon = MoonPhases.new
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", moon.lookupURL( 0 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", moon.lookupURL( -1 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", moon.lookupURL( -99 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0199.html", moon.lookupURL( -100 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0199.html", moon.lookupURL( -199 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0299.html", moon.lookupURL( -200 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0999.html", moon.lookupURL( -900 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0999.html", moon.lookupURL( -999 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-1099.html", moon.lookupURL( -1000 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-1099.html", moon.lookupURL( -1099 )
  end
  
  def test_padding
    moon = MoonPhases.new
    assert_equal "0001", moon.paddedString( 1 )
    assert_equal "0010", moon.paddedString( 10 )
    assert_equal "0100", moon.paddedString( 100 )
    assert_equal "1000", moon.paddedString( 1000 )
  end
  
  def test_get_data
    moon = MoonPhases.new
    assert_raise OpenURI::HTTPError do
      moon.getNASADoc( 50000 )
    end
    
    assert_nothing_raised OpenURI::HTTPError do
      doc = moon.getNASADoc 2012
      assert_equal "NASA - Moon Phases:  2001 to  2100", doc.title
    end
  end
  
  def test_find_year_blobs
    moon = MoonPhases.new
      doc = moon.getNASADoc 2012
      assert_not_nil moon.findYearIn doc, 2012
      assert_nil moon.findYearIn doc, 1999    

      # Some AD Years      
      assert_equal 2015, (moon.getNASAYearBlob 2015).content[/-?\d+/].to_i
      assert_equal 9, (moon.getNASAYearBlob 9).content[/-?\d+/].to_i
      assert_equal 567, (moon.getNASAYearBlob 567).content[/-?\d+/].to_i
      assert_equal 1620, (moon.getNASAYearBlob 1620).content[/-?\d+/].to_i
      
      # OOH!  Year 0!
      assert_equal 0, (moon.getNASAYearBlob 0).content[/-?\d+/].to_i
      
      # How about some BC Years?
      assert_equal -1, (moon.getNASAYearBlob -1).content[/-?\d+/].to_i
      assert_equal -980, (moon.getNASAYearBlob -980).content[/-?\d+/].to_i
      assert_equal -38, (moon.getNASAYearBlob -38).content[/-?\d+/].to_i
      
      # These are the earliest and latest years for which NASA publishes data.
      assert_equal -1999, (moon.getNASAYearBlob -1999).content[/-?\d+/].to_i
      assert_equal 4000, (moon.getNASAYearBlob 4000).content[/-?\d+/].to_i

  end
  
  def test_parse_blob_data
    moon = MoonPhases.new
    assert_equal 2002, (moon.getNASAYearBlob 2002).content[/-?\d+/].to_i
    assert_equal 13, (moon.separateNASADataLines 2002).length
    
    #Now let's see if we're actually parsing good data.
    moonData = moon.getNASAData( 2002 )
    assert_equal 49, moonData.getNumDataPoints
    assert_equal 2002, moonData.getYear
    
    parsedDate = moonData.parseDate( "Jan 12 23:46" )
    assert_equal 2002, parsedDate.year
    assert_equal 1, parsedDate.mon
    assert_equal 12, parsedDate.mday
    
    assert_equal 1, moonData.parseDate( "Jan 10  12:03" ).mon     
    assert_equal 2, moonData.parseDate( "    Feb  8  22:28     " ).mon   
    assert_equal 3, moonData.parseDate( "    Mar 25  20:58     " ).mon   
    assert_equal 4, moonData.parseDate( "    Apr  2  00:50    " ).mon   
    assert_equal 5, moonData.parseDate( "    May  1  06:24    " ).mon   
    assert_equal 6, moonData.parseDate( "    Jun 15  01:22     " ).mon   
    assert_equal 7, moonData.parseDate( "    Jul  6  12:03    " ).mon   
    assert_equal 8, moonData.parseDate( "     Aug 19  17:53" ).mon        
    assert_equal 9, moonData.parseDate( "   Sep  3  18:45     " ).mon   
    assert_equal 10, moonData.parseDate( " Oct 25  01:17    " ).mon   
    assert_equal 11, moonData.parseDate( " Nov  2  01:25    " ).mon   
    assert_equal 12, moonData.parseDate( "Dec 31  03:12  " ).mon   
  end
  
  
  def test_document_log
    moon = MoonPhases.new
    
    # Get a document, and make sure an item is added to the log.
    assert_not_nil moon.getNASAYearBlob 1977
    assert_equal 1, moon.getDocumentLogLength

    # Get another doc, and make sure another item is added to the log.
    moon.getNASAYearBlob 2011
    assert_not_nil assert_equal 2, moon.getDocumentLogLength

    #Make sure that the log contains what we think it should.    
    assert_equal moon.lookupURL( 2011 ), moon.getDocumentLogItem( 1 )
    assert_equal moon.lookupURL( 1977 ), moon.getDocumentLogItem( 0 )
    
    # Get a blob we've gotten before, and make sure that
    # the log DOESN'T grow (because we went to the cache).
    assert_not_nil  moon.getNASAYearBlob 1977
    assert_equal 2, moon.getDocumentLogLength
    
    # Get a blob from the year after that one (1977 & 1978) 
    # should be in the same NASA page, and make sure that the
    # log doesn't grow.
    assert_not_nil moon.getNASAYearBlob 1978
    assert_equal 2, moon.getDocumentLogLength
  end
end
