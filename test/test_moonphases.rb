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
    assert_equal 1, moonData.getDataPoint( 0 ).getDate.mon
    assert_equal 6, moonData.getDataPoint( 0 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 0 ).getDate.year 

    assert_equal 1, moonData.getDataPoint( 1 ).getDate.mon
    assert_equal 13, moonData.getDataPoint( 1 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 1 ).getDate.year 

    assert_equal 1, moonData.getDataPoint( 2 ).getDate.mon
    assert_equal 21, moonData.getDataPoint( 2 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 2 ).getDate.year 

    assert_equal 1, moonData.getDataPoint( 3 ).getDate.mon
    assert_equal 28, moonData.getDataPoint( 3 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 3 ).getDate.year 

    assert_equal 2, moonData.getDataPoint( 4 ).getDate.mon
    assert_equal 4, moonData.getDataPoint( 4 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 4 ).getDate.year 

    assert_equal 2, moonData.getDataPoint( 5 ).getDate.mon
    assert_equal 12, moonData.getDataPoint( 5 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 5 ).getDate.year 

    assert_equal 2, moonData.getDataPoint( 6 ).getDate.mon
    assert_equal 20, moonData.getDataPoint( 6 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 6 ).getDate.year 

    assert_equal 2, moonData.getDataPoint( 7 ).getDate.mon
    assert_equal 27, moonData.getDataPoint( 7 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 7 ).getDate.year 

    assert_equal 3, moonData.getDataPoint( 8 ).getDate.mon
    assert_equal 6, moonData.getDataPoint( 8 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 8 ).getDate.year 

    assert_equal 3, moonData.getDataPoint( 9 ).getDate.mon
    assert_equal 14, moonData.getDataPoint( 9 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 9 ).getDate.year 

    assert_equal 3, moonData.getDataPoint( 10 ).getDate.mon
    assert_equal 22, moonData.getDataPoint( 10 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 10 ).getDate.year 

    assert_equal 3, moonData.getDataPoint( 11 ).getDate.mon
    assert_equal 28, moonData.getDataPoint( 11 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 11 ).getDate.year 

    assert_equal 4, moonData.getDataPoint( 12 ).getDate.mon
    assert_equal 4, moonData.getDataPoint( 12 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 12 ).getDate.year 

    assert_equal 4, moonData.getDataPoint( 13 ).getDate.mon
    assert_equal 12, moonData.getDataPoint( 13 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 13 ).getDate.year 

    assert_equal 4, moonData.getDataPoint( 14 ).getDate.mon
    assert_equal 20, moonData.getDataPoint( 14 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 14 ).getDate.year 

    assert_equal 4, moonData.getDataPoint( 15 ).getDate.mon
    assert_equal 27, moonData.getDataPoint( 15 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 15 ).getDate.year 

    assert_equal 5, moonData.getDataPoint( 16 ).getDate.mon
    assert_equal 4, moonData.getDataPoint( 16 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 16 ).getDate.year 

    assert_equal 5, moonData.getDataPoint( 17 ).getDate.mon
    assert_equal 12, moonData.getDataPoint( 17 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 17 ).getDate.year 

    assert_equal 5, moonData.getDataPoint( 18 ).getDate.mon
    assert_equal 19, moonData.getDataPoint( 18 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 18 ).getDate.year 

    assert_equal 5, moonData.getDataPoint( 19 ).getDate.mon
    assert_equal 26, moonData.getDataPoint( 19 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 19 ).getDate.year 

    assert_equal 6, moonData.getDataPoint( 20 ).getDate.mon
    assert_equal 3, moonData.getDataPoint( 20 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 20 ).getDate.year 

    assert_equal 6, moonData.getDataPoint( 21 ).getDate.mon
    assert_equal 10, moonData.getDataPoint( 21 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 21 ).getDate.year 

    assert_equal 6, moonData.getDataPoint( 22 ).getDate.mon
    assert_equal 18, moonData.getDataPoint( 22 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 22 ).getDate.year 

    assert_equal 6, moonData.getDataPoint( 23 ).getDate.mon
    assert_equal 24, moonData.getDataPoint( 23 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 23 ).getDate.year 

    assert_equal 7, moonData.getDataPoint( 24 ).getDate.mon
    assert_equal 2, moonData.getDataPoint( 24 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 24 ).getDate.year 

    assert_equal 7, moonData.getDataPoint( 25 ).getDate.mon
    assert_equal 10, moonData.getDataPoint( 25 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 25 ).getDate.year 

    assert_equal 7, moonData.getDataPoint( 26 ).getDate.mon
    assert_equal 17, moonData.getDataPoint( 26 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 26 ).getDate.year 

    assert_equal 7, moonData.getDataPoint( 27 ).getDate.mon
    assert_equal 24, moonData.getDataPoint( 27 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 27 ).getDate.year 

    assert_equal 8, moonData.getDataPoint( 28 ).getDate.mon
    assert_equal 1, moonData.getDataPoint( 28 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 28 ).getDate.year 

    assert_equal 8, moonData.getDataPoint( 29 ).getDate.mon
    assert_equal 8, moonData.getDataPoint( 29 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 29 ).getDate.year 

    assert_equal 8, moonData.getDataPoint( 30 ).getDate.mon
    assert_equal 15, moonData.getDataPoint( 30 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 30 ).getDate.year 

    assert_equal 8, moonData.getDataPoint( 31 ).getDate.mon
    assert_equal 22, moonData.getDataPoint( 31 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 31 ).getDate.year 

    assert_equal 8, moonData.getDataPoint( 32 ).getDate.mon
    assert_equal 31, moonData.getDataPoint( 32 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 32 ).getDate.year 

    assert_equal 9, moonData.getDataPoint( 33 ).getDate.mon
    assert_equal 7, moonData.getDataPoint( 33 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 33 ).getDate.year 

    assert_equal 9, moonData.getDataPoint( 34 ).getDate.mon
    assert_equal 13, moonData.getDataPoint( 34 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 34 ).getDate.year 

    assert_equal 9, moonData.getDataPoint( 35 ).getDate.mon
    assert_equal 21, moonData.getDataPoint( 35 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 35 ).getDate.year 

    assert_equal 9, moonData.getDataPoint( 36 ).getDate.mon
    assert_equal 29, moonData.getDataPoint( 36 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 36 ).getDate.year 

    assert_equal 10, moonData.getDataPoint( 37 ).getDate.mon
    assert_equal 6, moonData.getDataPoint( 37 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 37 ).getDate.year 

    assert_equal 10, moonData.getDataPoint( 38 ).getDate.mon
    assert_equal 13, moonData.getDataPoint( 38 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 38 ).getDate.year 

    assert_equal 10, moonData.getDataPoint( 39 ).getDate.mon
    assert_equal 21, moonData.getDataPoint( 39 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 39 ).getDate.year 

    assert_equal 10, moonData.getDataPoint( 40 ).getDate.mon
    assert_equal 29, moonData.getDataPoint( 40 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 40 ).getDate.year 

    assert_equal 11, moonData.getDataPoint( 41 ).getDate.mon
    assert_equal 4, moonData.getDataPoint( 41 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 41 ).getDate.year 

    assert_equal 11, moonData.getDataPoint( 42 ).getDate.mon
    assert_equal 11, moonData.getDataPoint( 42 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 42 ).getDate.year 

    assert_equal 11, moonData.getDataPoint( 43 ).getDate.mon
    assert_equal 20, moonData.getDataPoint( 43 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 43 ).getDate.year 

    assert_equal 11, moonData.getDataPoint( 44 ).getDate.mon
    assert_equal 27, moonData.getDataPoint( 44 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 44 ).getDate.year 

    assert_equal 12, moonData.getDataPoint( 45 ).getDate.mon
    assert_equal 4, moonData.getDataPoint( 45 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 45 ).getDate.year 

    assert_equal 12, moonData.getDataPoint( 46 ).getDate.mon
    assert_equal 11, moonData.getDataPoint( 46 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 46 ).getDate.year 

    assert_equal 12, moonData.getDataPoint( 47 ).getDate.mon
    assert_equal 19, moonData.getDataPoint( 47 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 47 ).getDate.year 

    assert_equal 12, moonData.getDataPoint( 48 ).getDate.mon
    assert_equal 27, moonData.getDataPoint( 48 ).getDate.mday  
    assert_equal 2002, moonData.getDataPoint( 48 ).getDate.year 

  end
  
  def test_find_surrounding_data
    if !(defined? @moon)
      @moon = MoonPhases.new
    end

    testDate = Date.new 2011, 5, 5
    
    dateBefore = (@moon.getPreviousDataPoint testDate).getDate
    assert_equal 5, dateBefore.mon
    assert_equal 3, dateBefore.mday
    assert_equal 2011, dateBefore.year
    
    dateAfter = (@moon.getNextDataPoint testDate).getDate
    assert_equal 5, dateAfter.mon
    assert_equal 10, dateAfter.mday
    assert_equal 2011, dateAfter.year
    
    testDate = Date.new 2001, 1, 1
    dateBefore = (@moon.getPreviousDataPoint testDate).getDate
    assert_equal 12, dateBefore.mon
    assert_equal 25, dateBefore.mday
    assert_equal 2000, dateBefore.year
    
    testDate = Date.new 2000, 12, 26
    dateAfter = (@moon.getNextDataPoint testDate).getDate
    assert_equal 1, dateAfter.mon
    assert_equal 2, dateAfter.mday
    assert_equal 2001, dateAfter.year
    
    testDate = Date.new 2000, 12, 25
    assert_equal @moon.getPreviousDataPoint( testDate ).getDate, @moon.getNextDataPoint( testDate ).getDate
  end  
  
  def test_get_moon_phase
    if !(defined? @moon)
      @moon = MoonPhases.new
    end
 
    assert_equal 50, @moon.getMoonFullness( Date.new 2005, 1, 3 ).getPercent
    assert_equal "-", @moon.getMoonFullness( Date.new 2005, 1, 3 ).getDirection
    assert_equal 0, @moon.getMoonFullness( Date.new 2005, 5, 8 ).getPercent
    assert_equal 50, @moon.getMoonFullness( Date.new 2005, 5, 16 ).getPercent
    assert_equal 100, @moon.getMoonFullness( Date.new 2005, 8, 19 ).getPercent
    
    testFullness = @moon.getMoonFullness( Date.new 2005, 6, 10 )
    assert testFullness.getPercent > 0 && testFullness.getPercent < 50
    assert @moon.getMoonFullness( Date.new 2005, 6, 11 ).getPercent > @moon.getMoonFullness( Date.new 2005, 6, 9 ).getPercent
    assert @moon.getMoonFullness( Date.new 2005, 6, 10 ).getDirection == "+"
    assert @moon.getMoonFullness( Date.new 2005, 6, 25 ).getDirection == "-"
    
    testFullness = @moon.getMoonFullness( Date.new 2005, 6, 25 )
    assert testFullness.getPercent < 100 && testFullness.getPercent > 50
    
    testFullness = @moon.getMoonFullness( Date.new 2004, 5, 12 )
    assert testFullness.getPercent < 50 && testFullness.getPercent > 0
    assert testFullness.getDirection == "-"
    
    fullnesses = Array.new
    for mday in 1..31 do
      fullnesses << @moon.getMoonFullness( Date.new 2003, 1, mday )
    end
    
    assert fullnesses[1].getPercent < fullnesses[0].getPercent
    for mday in 2..17 do
      assert fullnesses[mday].getPercent > fullnesses[mday-1].getPercent
    end
    for mday in 18..30 do
      assert fullnesses[mday].getPercent < fullnesses[mday-1].getPercent
    end
    
    assert fullnesses[2].getPercent - fullnesses[1].getPercent == fullnesses[9].getPercent - fullnesses[8].getPercent
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
