class MoonPhases
  def self.lookupURL( year )
    "http://eclipse.gsfc.nasa.gov/phase/phases" + paddedString( (( year - 1 )/ 100 ) * 100 + 1 ) + ".html"
  end
  
  def self.paddedString( value )
    if value < 10
      "000" + value.to_s
    elsif value < 100
      "00" + value.to_s
    elsif value < 1000
      "0" + value.to_s
    else
      value.to_s
    end
  end
end