require 'test/unit'
require 'moonphases'

class MoonPhasesTest < Test::Unit::TestCase
  def test_spoutBack
    assert_equal "myMessage is the message I'm sending back!", MoonPhases.spoutBack( "myMessage" )
  end
end
