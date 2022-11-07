require 'json'

module Battlesnake
  ##
  # Represents a single iteration (turn) of a Battlesnake board during gameplay.
  class Board < Base
    # @return [Hash] board as a data structure usable by other objects.
    attr_reader :as_json

    # @return [Integer] height of the board
    attr_reader :height

    # @return [Integer] width of the board
    attr_reader :width

    # @return [Array<Snake>] list of snake objects
    attr_reader :snakes

    # @return [Array<Location>] list of food location objects
    attr_reader :food

    # @return [Array<Location>] list of hazard location objects
    attr_reader :hazards

    ##
    # Returns a new instance of Board.
    #
    # @param json_or_hash [String,Hash] can be a hash of attributes, or a JSON string which
    #   represents such a structure.
    #
    # @return [Board]
    def initialize(json_or_hash)
      data = json_or_hash.is_a?(String) ? JSON.parse(json_or_hash) : json_or_hash

      @as_json = data
      @height = data['height']
      @width = data['width']
      @snakes = data['snakes'].map{ |attrs| Snake.new(attrs) }
      @food = data['food'].map{ |attrs| Location.new(attrs) }
      @hazards = data['hazards'].map{ |attrs| Location.new(attrs) }
    end

    ##
    # List of all occupied locations on the board; snakes, food, hazards, etc
    #
    # @return [Array<Location>] list of occupied locations
    def occupied_locations
      return @occupied_locations if defined?(@occupied_locations)
      @occupied_locations = snakes.map(&:body).flatten + food + hazards
    end

    ##
    # Whether the supplied location is occupied.
    #
    # @param [Location] location being checked for occupancy.
    #
    # @return [Boolean] true if location is occupied by snakes, food, hazards, etc.
    def occupied?(location)
      occupied_locations.include?(location)
    end

    ##
    # Where the supplied location falls within the boundaries of the board.
    #
    # @param [Location] location being tested.
    #
    # @return [Boolean] true if location is within the boundaries of the board.
    def on_board?(location)
      location.x >= 0 && location.y >= 0 && location.x < width && location.y < height
    end

    ##
    # Whether the supplied location is available (unoccupied).
    #
    # @param [Location] location being tested for availability.
    #
    # @return [Boolean] true if location is available (unoccupied by snakes, food, hazards, etc).
    def available?(location)
      on_board?(location) && !occupied?(location)
    end

    ##
    # List of directions (up, down, left, right) available for moving from given _Location_.
    #
    # @param [Location] location from which moving is desired.
    #
    # @return [Array<String>] list of direction strings ("up", "down", "left", "right")
    def available_directions(location)
      Location::DIRECTIONS.select do |direction|
        available?(location.move(direction))
      end
    end
  end
end