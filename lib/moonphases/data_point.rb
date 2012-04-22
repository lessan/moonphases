require 'date'

class DataPoint
  def initialize( date, fullness )
    @date = date
    @fullness = fullness
  end
  
  def getDate
    @date
  end
  
  def getFullness
    @fullness
  end
end

class Fullness
  def initialize( percent, direction )
    @percent = percent
    @direction = direction
  end
  
  def getPercent
    @percent
  end
  
  def getDirection
    @direction
  end
end
