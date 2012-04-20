require 'nokogiri'
require 'open-uri'

class MoonPhases
  def initialize
    @documentLog = Array.new  
    @blobCache = Hash.new
  end
  
  def getDocumentLogItem( item )
    @documentLog[ item ]
  end
  
  def getNASAYearBlob( year )
    doc = @blobCache[ year ]
    if doc.nil?
      doc = getNASADoc year
      @blobCache[ year ] = doc
    end
    if !doc.nil?
      return findYearIn doc, year
    end
    nil
  end
  
  def getDocumentLogLength
    @documentLog.length
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
    url = lookupURL( year )
    @documentLog << url
    Nokogiri::HTML( open( url ))
  end
  
  def lookupURL( year )
    "http://eclipse.gsfc.nasa.gov/phase/phases" + paddedString( (( year - 1 )/ 100 ) * 100 + 1 ) + ".html"
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