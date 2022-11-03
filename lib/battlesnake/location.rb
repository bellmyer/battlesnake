require 'json'

module Battlesnake
  class Location
    attr_reader :x, :y

    DIRECTIONS = ['up', 'down', 'right', 'left']

    def initialize(*coordinates)
      set_xy(*coordinates)
    end

    def coords
      return @coords if defined?(@coords)
      @coords = [x, y]
    end

    def distance(location)
      [delta_x(location).abs, delta_y(location).abs].reduce(:+)
    end

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