require 'json'

module Battlesnake
  class Location
    attr_reader :x, :y

    def initialize(*coords)
      set_xy(*coords)
    end

    def distance(location)
      [(location.x - x).abs, (location.y - y).abs].reduce(:+)
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
  end
end