require 'json'

module Battlesnake
  ##
  # Represents a single Battlesnake player.
  class Snake < Base
    # @return [Hash] snake as a data structure usable by other objects.
    attr_reader :as_json

    # @return [String] unique string which identifies the player.
    attr_reader :id

    # @return [String] name of the player.
    attr_reader :name

    # @return [Array<Location>] locations occupied by the body of the snake.
    attr_reader :body

    # @return [Integer] latency of given player's API, _nil_ if not provided.
    attr_reader :latency

    # @return [Integer] health value between 0 and 100.
    attr_reader :health

    # @return [Location] location of snake head. Should be the same as body[0].
    attr_reader :head

    # @return [Integer] number of locations occupied by snake body.
    attr_reader :length

    # @return [String] message to other players.
    attr_reader :shout

    # @return [String] squad identifer for games played with teams.
    attr_reader :squad

    # @return [Hash] display customizations.
    attr_reader :customizations

    ##
    # Returns a new instance of Snake.
    #
    # @param json_or_hash [String,Hash] can be a hash of attributes, or a JSON string which
    #   represents such a structure.
    #
    # @return [Snake]
    def initialize(json_or_hash)
      @as_json = json_or_hash.is_a?(String) ? JSON.parse(json_or_hash) : json_or_hash

      @id = @as_json['id']
      @name = @as_json['name']
      @latency = @as_json['latency'].empty? ? nil : @as_json['latency'].to_i
      @health = @as_json['health']
      @length = @as_json['length']
      @shout = @as_json['shout']
      @squad = @as_json['squad']
      @customizations = @as_json['customizations']

      @body = @as_json['body'].map{ |coords| Location.new(coords) }
      @head = Location.new(@as_json['head'])
    end

    ##
    # The current direction the snake is facing, based on the first two segments
    # of the body. If snake only has a head, no direction can be determined, so
    # _nil_ is returned.
    #
    # @return [String] one of (up, down, left, right)
    def direction
      return @direction if defined?(@direction)
      @direction = length > 1 ? body[1].direction(head) : nil
    end
  end
end