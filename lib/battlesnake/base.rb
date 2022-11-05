module Battlesnake
  ##
  # Base class for "model" classes - _Game, Board, Snake, Location,_ etc.
  class Base
    ##
    # Whether both locations have the same coordinates.
    #
    # @param other [Location]
    #
    # @return [Boolean] true if location objects have the same coordinates.
    def ==(other)
      other.is_a?(self.class) && self.as_json == other.as_json
    end
  end
end