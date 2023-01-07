module Battlesnake
  ##
  # Represents a single iteration (turn) of a Battlesnake game.
  class Turn < Base
    # @return [Hash] board as a data structure usable by other objects.
    attr_reader :as_json

    # @return [Hash] game attributes as a data structure.
    attr_reader :game

    # @return [Board] board attributes as a Board object.
    attr_reader :board

    # @return [Snake] your own snake attributes as a Snake object.
    attr_reader :you

    ##
    # Returns a new instance of Turn.
    #
    # @param json_or_hash [String,Hash] can be a hash of attributes, or a JSON string which
    #   represents such a structure.
    #
    # @return [Turn]
    def initialize(json_or_hash)
      data = json_or_hash.is_a?(String) ? JSON.parse(json_or_hash) : json_or_hash

      @as_json = data
      @game = data['game']
      @board = Board.new(data['board'])
      @you = Snake.new(data['you'])
    end
  end
end