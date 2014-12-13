require 'date'

class DataPoint
  def initialize( date, time, fullness )
    @date = date
    @time = time
    @fullness = fullness
  end
  
  def getDate
    @date
  end

  def getTime
    @time
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
