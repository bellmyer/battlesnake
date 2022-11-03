require 'json'

module Battlesnake
  class Location
    attr_reader :x, :y

    def initialize(*coords)
      set_xy(*coords)
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

    private

    def set_xy(*coords)
      unless coords.is_a?(Array) && coords.size == 2
        coords = coords.first
      end

      case coords
      when Hash
        hash_to_xy(coords)
      when String
        hash_to_xy(JSON.parse(coords))
      when Array
        array_to_xy(coords)
      end
    end

    def hash_to_xy(coords)
      @x = coords['x']
      @y = coords['y']
    end

    def array_to_xy(coords)
      @x, @y = coords
    end

    def delta_x(location)
      location.x - x
    end

    def delta_y(location)
      location.y - y
    end
  end
end