require 'json'

module Battlesnake
  ##
  # Represents a Battlesnake game.
  class Game < Base
    # @return [Hash] snake as a data structure usable by other objects.
    attr_reader :as_json

    # @return [String] unique identifier for this game.
    attr_reader :id

    # @return [Hash] information about the ruleset being used to run this game.
    attr_reader :ruleset

    # @return [String] name of the map used to populate the game board with snakes, food, and hazards.
    attr_reader :map

    # @return [Integer] how much time player APIs have to respond to requests for this game.
    attr_reader :timeout

    # @return [String] source of this game.
    attr_reader :source

    ##
    # Returns a new instance of Game.
    #
    # @param json_or_hash [String,Hash] can be a hash of attributes, or a JSON string which
    #   represents such a structure.
    #
    # @return [Game]
    def initialize(json_or_hash)
      data = json_or_hash.is_a?(String) ? JSON.parse(json_or_hash) : json_or_hash

      @as_json = data

      @id = data['id']
      @ruleset = data['ruleset']
      @map = data['map']
      @timeout = data['timeout']
      @source = data['source']
    end
  end
end