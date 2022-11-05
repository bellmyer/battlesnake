require 'json'

module Battlesnake
  ##
  # Represents a single iteration (turn) of a Battlesnake board during gameplay.
  class Board
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
  end
end