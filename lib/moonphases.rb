require 'nokogiri'
require 'open-uri'

class MoonPhases
  def self.getNASAYearBlob( year )
    doc = getNASADoc year
    if !doc.nil?
      return findYearIn doc, year
    end
    nil
  end
  
  def self.findYearIn( nasaDoc, year )
    nasaDoc.css( 'pre.indent' ).each do |pre|
      pre.children.each do |child|
        firstNumber = child.content[/\d+/]
        if !firstNumber.nil?
          if firstNumber.to_i == year
            return child
          end
        end
      end
    end
    nil
  end
  
  def self.getNASADoc( year )
    Nokogiri::HTML( open( lookupURL( year )))
  end
  
  def self.lookupURL( year )
    "http://eclipse.gsfc.nasa.gov/phase/phases" + paddedString( (( year - 1 )/ 100 ) * 100 + 1 ) + ".html"
  end
  
  def self.paddedString( value )
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