require 'json'

module Battlesnake
  ##
  # Represents a pair of (x,y) coordinates, and provides helper methods
  # for managing distance and direction.
  class Location
    # @return [Integer] a positive integer representing the distance from the
    #   left side of the board.
    attr_reader :x

    # @return [Integer] a positive integer representing the distance from the
    #   bottom of the board.
    attr_reader :y

    # @return [Hash] coordinates as a hash, for integration with other objects.
    attr_reader :as_json

    # Valid directions.
    DIRECTIONS = ['up', 'down', 'right', 'left']

    ##
    # Instantiates with the given (x,y) coordinates. Coordinates can be:
    # * a hash containing "x" and "y" keys
    # * a JSON string that parses to such a hash
    # * an array containing (x,y) coordinates
    # * two separate (x,y) parameters
    #
    # @param coordinates [Hash, Array, String] the coordinates
    #
    # @return [Location] a new location object with (x,y) coordinates set.
    def initialize(*coordinates)
      set_xy(*coordinates)

      @as_json = {'x' => x, 'y' => y}
    end

    ##
    # Convenience method to return (x,y) coordinates as an array.
    #
    # @return [Array]
    def coords
      return @coords if defined?(@coords)
      @coords = [x, y]
    end

    ##
    # Calculate the distance from this instance to another.
    #
    # @param location [Location] another Location instance.
    #
    # @return [Integer] the number of blocks away, in "manhattan distance".
    def distance(location)
      [delta_x(location).abs, delta_y(location).abs].reduce(:+)
    end

    ##
    # Determine the most prominent orthoganal direction [see DIRECTIONS]
    # toward another location.
    #
    # @note Returns _nil_ if the locations are the same. Favors "up" or "down"
    #   if horizontal and vertical distances are the same.
    #
    # @param location [Location] another location instance.
    #
    # @return [one of DIRECTIONS]
    def direction(location)
      return nil if distance(location) == 0

      dx = delta_x(location)
      dy = delta_y(location)

      if dx.abs <= dy.abs
        dy > 0 ? 'up' : 'down'
      elsif dx.abs > dy.abs
        dx > 0 ? 'right' : 'left'
      end
    end

    ##
    # Return a new location instance with coordinates moved one step in the requested direction.
    #
    # @note Returns _nil_ if the requested direction is not recognized.
    #
    # @param requested_direction [one of DIRECTIONS]
    #
    # @return [Location] a new location instance.
    def move(requested_direction)
      return nil unless DIRECTIONS.include?(requested_direction)

      new_x = x
      new_y = y

      case requested_direction
      when 'right'
        new_x += 1
      when 'left'
        new_x -= 1
      when 'up'
        new_y += 1
      when 'down'
        new_y -= 1
      end

      self.class.new(new_x, new_y)
    end

    private

    def set_xy(*coordinates)
      unless coordinates.is_a?(Array) && coordinates.size == 2
        coordinates = coordinates.first
      end

      case coordinates
      when Hash
        hash_to_xy(coordinates)
      when String
        hash_to_xy(JSON.parse(coordinates))
      when Array
        array_to_xy(coordinates)
      end
    end

    def hash_to_xy(coordinates)
      @x = coordinates['x']
      @y = coordinates['y']
    end

    def array_to_xy(coordinates)
      @x, @y = coordinates
    end

    def delta_x(location)
      location.x - x
    end

    def delta_y(location)
      location.y - y
    end
  end
end