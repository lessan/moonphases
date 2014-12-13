require 'nokogiri'
require 'open-uri'
require 'moonphases/moon_data'

class MoonPhases
  def initialize
    @documentLog = Array.new  
    @documentCache = Hash.new
  end
  
  def getDocumentLogItem( item )
    @documentLog[ item ]
  end
  
  def getNASAYearBlob( year )
    doc = getNASADoc year
    if !doc.nil?
      return findYearIn doc, year
    end
    nil
  end
  
  def getMoonFullness( date )
    pDataPoint = getPreviousDataPoint date
    if pDataPoint.getDate == date 
      return pDataPoint.getFullness
    end

    nDataPoint = getNextDataPoint date
    daysBetweenDataPoints = nDataPoint.getDate.ajd - pDataPoint.getDate.ajd
    daysSincePreviousDataPoint = date.ajd - pDataPoint.getDate.ajd
     
    phaseChange = (nDataPoint.getFullness.getPercent - pDataPoint.getFullness.getPercent) * ( daysSincePreviousDataPoint / daysBetweenDataPoints ) 
    Fullness.new pDataPoint.getFullness.getPercent + phaseChange, phaseChange > 0 ? "+" : "-"
  end
  
  def getDocumentLogLength
    @documentLog.length
  end
  
  def getNASAData( year )
    MoonData.new separateNASADataLines( year )
  end
  
  def getPreviousDataPoint( date )
    yearToCheck = date.year
    while !(yearData = getNASAData yearToCheck ).nil?
      index = yearData.getNumDataPoints-1
    
      while index >= 0
        testDate = yearData.getDataPoint index
       if testDate.getDate <= date
         return testDate
       end
       index = index-1
     end
     yearToCheck = yearToCheck-1    
    end
    nil
  end
  
  def getNextDataPoint( date )
    yearToCheck = date.year
    while !(yearData = getNASAData yearToCheck ).nil?
      index = 0
    
      while index < yearData.getNumDataPoints
        testDate = yearData.getDataPoint index
       if( testDate.getDate >= date )
         return testDate
       end
       index = index+1
      end
      yearToCheck = yearToCheck+1
    end
    nil
  end
 
  def getNextMoonByPercent( date, percent )
    dataPoint = getNextDataPoint(date)
    if (dataPoint.getFullness.getPercent == percent)
      return dataPoint
    end
    return getNextMoonByPercent(dataPoint.getDate + 1, percent)
  end
 
  def separateNASADataLines( year )
    dataLines = Array.new
    # Remove blank lines and stupid OSX return characters.
    data = (getNASAYearBlob year).content
    data.scan(/([^\r]*)/).each do |line|
      if line[0].length > 0
        dataLines << line[0]
      end
    end
    #puts data.scan(/^(-?\d+)?(\s*)(([A-Za-z]{3}\s+\d+\s+\d+:\d+\s+[TAHPtpn]?\s*){1,4})(\d\dh\d\dm)?\s*$/).inspect
    #(getNASAYearBlob year).content.scan(/^(-?\d+)?( *)(([A-Za-z]{3} +\d+ +\d+:\d+ +[TAHPtpn]? *){1,4})(\d\dh\d\dm)? *$/).each do |lineMatches|
    #  puts lineMatches[2]
    #  dataLines << lineMatches[2]
    #end
    dataLines
  end
  
  def findYearIn( nasaDoc, year )
    nasaDoc.css( 'pre.indent' ).each do |pre|
      pre.children.each do |child|
        firstNumber = child.content[/-?\d+/]
        if !firstNumber.nil?
          if firstNumber.to_i == year
            return child
          end
        end
      end
    end
    nil
  end
  
  def getNASADoc( year )
    filename = lookupFilename( year )
    document = @documentCache[ filename ]
    if document.nil?
      @documentLog << filename
      document = Nokogiri::HTML( File.open( filename ))
      @documentCache[ filename ] = document  
    end
    document
  end
  
  def lookupFilename( year )
    File.join(File.dirname(File.expand_path(__FILE__)), 'moonphases/db/phases' + paddedString( (( year - 1 )/ 100 ) * 100 + 1 ) + ".html" )
  end
  
  def paddedString( value )
    if value > 0
      if value < 10
        "000" + value.to_s
      elsif value < 100
        "00" + value.to_s
      elsif value < 1000
        "0" + value.to_s
      else
        value.to_s
      end
    else
      if value < -999
        value.to_s
      elsif value < -99
        "-0" + (-value).to_s
      else
        "-00" + (-value).to_s
      end
    end
  end
end
