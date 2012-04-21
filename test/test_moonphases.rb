require 'test/unit'
require 'moonphases'
require 'date'

class MoonPhasesTest < Test::Unit::TestCase
  
  def test_AD_Years
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0001.html", @moon.lookupURL( 1 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0001.html", @moon.lookupURL( 100 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0101.html", @moon.lookupURL( 101 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0101.html", @moon.lookupURL( 200 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0201.html", @moon.lookupURL( 201 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0201.html", @moon.lookupURL( 300 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0301.html", @moon.lookupURL( 301 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases0901.html", @moon.lookupURL( 1000 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases1001.html", @moon.lookupURL( 1001 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases2001.html", @moon.lookupURL( 2012 )
  end

  def test_BC_Years
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", @moon.lookupURL( 0 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", @moon.lookupURL( -1 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0099.html", @moon.lookupURL( -99 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0199.html", @moon.lookupURL( -100 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0199.html", @moon.lookupURL( -199 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0299.html", @moon.lookupURL( -200 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0999.html", @moon.lookupURL( -900 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-0999.html", @moon.lookupURL( -999 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-1099.html", @moon.lookupURL( -1000 )
    assert_equal "http://eclipse.gsfc.nasa.gov/phase/phases-1099.html", @moon.lookupURL( -1099 )
  end
  
  def test_padding
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    assert_equal "0001", @moon.paddedString( 1 )
    assert_equal "0010", @moon.paddedString( 10 )
    assert_equal "0100", @moon.paddedString( 100 )
    assert_equal "1000", @moon.paddedString( 1000 )
  end
  
  def test_get_data
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    assert_raise OpenURI::HTTPError do
      @moon.getNASADoc( 50000 )
    end
    
    assert_nothing_raised OpenURI::HTTPError do
      doc = @moon.getNASADoc 2012
      assert_equal "NASA - Moon Phases:  2001 to  2100", doc.title
    end
  end
  
  def test_find_year_blobs
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

      doc = @moon.getNASADoc 2012
      assert_not_nil @moon.findYearIn doc, 2012
      assert_nil @moon.findYearIn doc, 1999    

      # Some AD Years      
      assert_equal 2015, (@moon.getNASAYearBlob 2015).content[/-?\d+/].to_i
      assert_equal 9, (@moon.getNASAYearBlob 9).content[/-?\d+/].to_i
      assert_equal 567, (@moon.getNASAYearBlob 567).content[/-?\d+/].to_i
      assert_equal 1620, (@moon.getNASAYearBlob 1620).content[/-?\d+/].to_i
      
      # OOH!  Year 0!
      assert_equal 0, (@moon.getNASAYearBlob 0).content[/-?\d+/].to_i
      
      # How about some BC Years?
      assert_equal -1, (@moon.getNASAYearBlob -1).content[/-?\d+/].to_i
      assert_equal -980, (@moon.getNASAYearBlob -980).content[/-?\d+/].to_i
      assert_equal -38, (@moon.getNASAYearBlob -38).content[/-?\d+/].to_i
      
      # These are the earliest and latest years for which NASA publishes data.
      assert_equal -1999, (@moon.getNASAYearBlob -1999).content[/-?\d+/].to_i
      assert_equal 4000, (@moon.getNASAYearBlob 4000).content[/-?\d+/].to_i

  end
  
  def test_parse_blob_data
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    assert_equal 2002, (@moon.getNASAYearBlob 2002).content[/-?\d+/].to_i
    assert_equal 13, (@moon.separateNASADataLines 2002).length
    
    #Now let's see if we're actually parsing good data.
    moonData = @moon.getNASAData( 2002 )
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
    
    # Let's see if the dates were parsed right for 2002
    assert_equal 1, moonData.getDataPoint( 0 ).mon
    assert_equal 6, moonData.getDataPoint( 0 ).mday  
    assert_equal 2002, moonData.getDataPoint( 0 ).year 

    assert_equal 1, moonData.getDataPoint( 1 ).mon
    assert_equal 13, moonData.getDataPoint( 1 ).mday  
    assert_equal 2002, moonData.getDataPoint( 1 ).year 

    assert_equal 1, moonData.getDataPoint( 2 ).mon
    assert_equal 21, moonData.getDataPoint( 2 ).mday  
    assert_equal 2002, moonData.getDataPoint( 2 ).year 

    assert_equal 1, moonData.getDataPoint( 3 ).mon
    assert_equal 28, moonData.getDataPoint( 3 ).mday  
    assert_equal 2002, moonData.getDataPoint( 3 ).year 

    assert_equal 2, moonData.getDataPoint( 4 ).mon
    assert_equal 4, moonData.getDataPoint( 4 ).mday  
    assert_equal 2002, moonData.getDataPoint( 4 ).year 

    assert_equal 2, moonData.getDataPoint( 5 ).mon
    assert_equal 12, moonData.getDataPoint( 5 ).mday  
    assert_equal 2002, moonData.getDataPoint( 5 ).year 

    assert_equal 2, moonData.getDataPoint( 6 ).mon
    assert_equal 20, moonData.getDataPoint( 6 ).mday  
    assert_equal 2002, moonData.getDataPoint( 6 ).year 

    assert_equal 2, moonData.getDataPoint( 7 ).mon
    assert_equal 27, moonData.getDataPoint( 7 ).mday  
    assert_equal 2002, moonData.getDataPoint( 7 ).year 

    assert_equal 3, moonData.getDataPoint( 8 ).mon
    assert_equal 6, moonData.getDataPoint( 8 ).mday  
    assert_equal 2002, moonData.getDataPoint( 8 ).year 

    assert_equal 3, moonData.getDataPoint( 9 ).mon
    assert_equal 14, moonData.getDataPoint( 9 ).mday  
    assert_equal 2002, moonData.getDataPoint( 9 ).year 

    assert_equal 3, moonData.getDataPoint( 10 ).mon
    assert_equal 22, moonData.getDataPoint( 10 ).mday  
    assert_equal 2002, moonData.getDataPoint( 10 ).year 

    assert_equal 3, moonData.getDataPoint( 11 ).mon
    assert_equal 28, moonData.getDataPoint( 11 ).mday  
    assert_equal 2002, moonData.getDataPoint( 11 ).year 

    assert_equal 4, moonData.getDataPoint( 12 ).mon
    assert_equal 4, moonData.getDataPoint( 12 ).mday  
    assert_equal 2002, moonData.getDataPoint( 12 ).year 

    assert_equal 4, moonData.getDataPoint( 13 ).mon
    assert_equal 12, moonData.getDataPoint( 13 ).mday  
    assert_equal 2002, moonData.getDataPoint( 13 ).year 

    assert_equal 4, moonData.getDataPoint( 14 ).mon
    assert_equal 20, moonData.getDataPoint( 14 ).mday  
    assert_equal 2002, moonData.getDataPoint( 14 ).year 

    assert_equal 4, moonData.getDataPoint( 15 ).mon
    assert_equal 27, moonData.getDataPoint( 15 ).mday  
    assert_equal 2002, moonData.getDataPoint( 15 ).year 

    assert_equal 5, moonData.getDataPoint( 16 ).mon
    assert_equal 4, moonData.getDataPoint( 16 ).mday  
    assert_equal 2002, moonData.getDataPoint( 16 ).year 

    assert_equal 5, moonData.getDataPoint( 17 ).mon
    assert_equal 12, moonData.getDataPoint( 17 ).mday  
    assert_equal 2002, moonData.getDataPoint( 17 ).year 

    assert_equal 5, moonData.getDataPoint( 18 ).mon
    assert_equal 19, moonData.getDataPoint( 18 ).mday  
    assert_equal 2002, moonData.getDataPoint( 18 ).year 

    assert_equal 5, moonData.getDataPoint( 19 ).mon
    assert_equal 26, moonData.getDataPoint( 19 ).mday  
    assert_equal 2002, moonData.getDataPoint( 19 ).year 

    assert_equal 6, moonData.getDataPoint( 20 ).mon
    assert_equal 3, moonData.getDataPoint( 20 ).mday  
    assert_equal 2002, moonData.getDataPoint( 20 ).year 

    assert_equal 6, moonData.getDataPoint( 21 ).mon
    assert_equal 10, moonData.getDataPoint( 21 ).mday  
    assert_equal 2002, moonData.getDataPoint( 21 ).year 

    assert_equal 6, moonData.getDataPoint( 22 ).mon
    assert_equal 18, moonData.getDataPoint( 22 ).mday  
    assert_equal 2002, moonData.getDataPoint( 22 ).year 

    assert_equal 6, moonData.getDataPoint( 23 ).mon
    assert_equal 24, moonData.getDataPoint( 23 ).mday  
    assert_equal 2002, moonData.getDataPoint( 23 ).year 

    assert_equal 7, moonData.getDataPoint( 24 ).mon
    assert_equal 2, moonData.getDataPoint( 24 ).mday  
    assert_equal 2002, moonData.getDataPoint( 24 ).year 

    assert_equal 7, moonData.getDataPoint( 25 ).mon
    assert_equal 10, moonData.getDataPoint( 25 ).mday  
    assert_equal 2002, moonData.getDataPoint( 25 ).year 

    assert_equal 7, moonData.getDataPoint( 26 ).mon
    assert_equal 17, moonData.getDataPoint( 26 ).mday  
    assert_equal 2002, moonData.getDataPoint( 26 ).year 

    assert_equal 7, moonData.getDataPoint( 27 ).mon
    assert_equal 24, moonData.getDataPoint( 27 ).mday  
    assert_equal 2002, moonData.getDataPoint( 27 ).year 

    assert_equal 8, moonData.getDataPoint( 28 ).mon
    assert_equal 1, moonData.getDataPoint( 28 ).mday  
    assert_equal 2002, moonData.getDataPoint( 28 ).year 

    assert_equal 8, moonData.getDataPoint( 29 ).mon
    assert_equal 8, moonData.getDataPoint( 29 ).mday  
    assert_equal 2002, moonData.getDataPoint( 29 ).year 

    assert_equal 8, moonData.getDataPoint( 30 ).mon
    assert_equal 15, moonData.getDataPoint( 30 ).mday  
    assert_equal 2002, moonData.getDataPoint( 30 ).year 

    assert_equal 8, moonData.getDataPoint( 31 ).mon
    assert_equal 22, moonData.getDataPoint( 31 ).mday  
    assert_equal 2002, moonData.getDataPoint( 31 ).year 

    assert_equal 8, moonData.getDataPoint( 32 ).mon
    assert_equal 31, moonData.getDataPoint( 32 ).mday  
    assert_equal 2002, moonData.getDataPoint( 32 ).year 

    assert_equal 9, moonData.getDataPoint( 33 ).mon
    assert_equal 7, moonData.getDataPoint( 33 ).mday  
    assert_equal 2002, moonData.getDataPoint( 33 ).year 

    assert_equal 9, moonData.getDataPoint( 34 ).mon
    assert_equal 13, moonData.getDataPoint( 34 ).mday  
    assert_equal 2002, moonData.getDataPoint( 34 ).year 

    assert_equal 9, moonData.getDataPoint( 35 ).mon
    assert_equal 21, moonData.getDataPoint( 35 ).mday  
    assert_equal 2002, moonData.getDataPoint( 35 ).year 

    assert_equal 9, moonData.getDataPoint( 36 ).mon
    assert_equal 29, moonData.getDataPoint( 36 ).mday  
    assert_equal 2002, moonData.getDataPoint( 36 ).year 

    assert_equal 10, moonData.getDataPoint( 37 ).mon
    assert_equal 6, moonData.getDataPoint( 37 ).mday  
    assert_equal 2002, moonData.getDataPoint( 37 ).year 

    assert_equal 10, moonData.getDataPoint( 38 ).mon
    assert_equal 13, moonData.getDataPoint( 38 ).mday  
    assert_equal 2002, moonData.getDataPoint( 38 ).year 

    assert_equal 10, moonData.getDataPoint( 39 ).mon
    assert_equal 21, moonData.getDataPoint( 39 ).mday  
    assert_equal 2002, moonData.getDataPoint( 39 ).year 

    assert_equal 10, moonData.getDataPoint( 40 ).mon
    assert_equal 29, moonData.getDataPoint( 40 ).mday  
    assert_equal 2002, moonData.getDataPoint( 40 ).year 

    assert_equal 11, moonData.getDataPoint( 41 ).mon
    assert_equal 4, moonData.getDataPoint( 41 ).mday  
    assert_equal 2002, moonData.getDataPoint( 41 ).year 

    assert_equal 11, moonData.getDataPoint( 42 ).mon
    assert_equal 11, moonData.getDataPoint( 42 ).mday  
    assert_equal 2002, moonData.getDataPoint( 42 ).year 

    assert_equal 11, moonData.getDataPoint( 43 ).mon
    assert_equal 20, moonData.getDataPoint( 43 ).mday  
    assert_equal 2002, moonData.getDataPoint( 43 ).year 

    assert_equal 11, moonData.getDataPoint( 44 ).mon
    assert_equal 27, moonData.getDataPoint( 44 ).mday  
    assert_equal 2002, moonData.getDataPoint( 44 ).year 

    assert_equal 12, moonData.getDataPoint( 45 ).mon
    assert_equal 4, moonData.getDataPoint( 45 ).mday  
    assert_equal 2002, moonData.getDataPoint( 45 ).year 

    assert_equal 12, moonData.getDataPoint( 46 ).mon
    assert_equal 11, moonData.getDataPoint( 46 ).mday  
    assert_equal 2002, moonData.getDataPoint( 46 ).year 

    assert_equal 12, moonData.getDataPoint( 47 ).mon
    assert_equal 19, moonData.getDataPoint( 47 ).mday  
    assert_equal 2002, moonData.getDataPoint( 47 ).year 

    assert_equal 12, moonData.getDataPoint( 48 ).mon
    assert_equal 27, moonData.getDataPoint( 48 ).mday  
    assert_equal 2002, moonData.getDataPoint( 48 ).year 

  end
  
  def test_find_surrounding_data
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    testDate = Date.new 2011, 5, 5
    
    dateBefore = @moon.getPreviousDataPoint testDate    
    assert_equal 5, dateBefore.mon
    assert_equal 3, dateBefore.mday
    assert_equal 2011, dateBefore.year
    
    dateAfter = @moon.getNextDataPoint testDate
    assert_equal 5, dateAfter.mon
    assert_equal 10, dateAfter.mday
    assert_equal 2011, dateAfter.year
    
    testDate = Date.new 2001, 1, 1
    dateBefore = @moon.getPreviousDataPoint testDate
    assert_equal 12, dateBefore.mon
    assert_equal 25, dateBefore.mday
    assert_equal 2000, dateBefore.year
    
    testDate = Date.new 2000, 12, 26
    dateAfter = @moon.getNextDataPoint testDate
    assert_equal 1, dateAfter.mon
    assert_equal 2, dateAfter.mday
    assert_equal 2001, dateAfter.year
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
