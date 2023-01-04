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
    # List of all occupied locations on the board; snakes, hazards, etc.
    # Does NOT include food, since we don't want to avoid that.
    #
    # @return [Array<Location>] list of occupied locations
    def occupied_locations
      return @occupied_locations if defined?(@occupied_locations)
      @occupied_locations = snakes.map(&:body).flatten + hazards
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
    # Whether the supplied location is food.
    #
    # @param [Location] location being tested for availability.
    #
    # @return [Boolean] true if location is food.
    def food?(location)
      food.include?(location)
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

    ##
    # List of valid, consecutive paths from one location to the next. Paths may not:
    #
    #  - wander outside board boundaries.
    #  - use the same location more than once.
    #  - contain occupied locations, EXCEPT the start/end locations.
    #
    # The exception for start/end locations allows us to generate paths, for example, from a snake
    # to a food location, without having to calulate the starting/ending permutations ourselves.
    #
    # @param from [Location] starting location, may be occupied
    # @param to   [Location] starting location, may be occupied
    #
    # @return [Array<Path>] a list of paths, which themselves are lists of consecutive, valid locations.
    def find_path(from, to, max_distance: nil)
      @paths = []
      @ideal_path_size = from.distance(to) + 1
      @shortest_path_size = max_distance || @ideal_path_size
      @ideal_path_size_found = false

      recursive_paths(from, to, [from])

      @paths.select{ |path| path.size == @shortest_path_size }.first
    end

    def recursive_paths(from, to, path)
      head = path.last

      # give up if path is too long already.
      return [] if path.size > @shortest_path_size || @ideal_path_size_found

      # if we've made it to "to", we have a successful candidate path.
      if head.as_json == to.as_json
        @paths << path
        @shortest_path_size = [@shortest_path_size, path.size].min
        @ideal_path_size_found = true if path.size == @ideal_path_size

        return path
      end

      available_directions(head).sort_by do |direction|
        # prefer to continue in same direction
        neck = path[-2]

        if neck && neck.direction(head) == direction
          0
        else
          rand
        end
      end.map do |direction|
        # convert direction string to a location
        head.move(direction)
      end.map do |location|
        # convert location to a full path
        path + [location]
      end.select do |candidate|
        # don't allow paths that overlap themselves
        candidate.size == candidate.uniq(&:as_json).size
      end.each do |candidate|
        # recurse into remaining candidate paths
        recursive_paths(from, to, candidate)
      end
    end

    def shorty(location)
      "#{location.x}:#{location.y}"
    end

    def shorties(list)
      case list.first
      when Array
        list.map{ |l| shorties(l) }
      when Location
        list.map{|x| shorty(x)}.join(' ')
      end
    end

    def print_grid(path, prefix: '  ')
      max_x = path.map(&:x).max
      max_y = path.map(&:y).max

      (0..max_y).each do |row|
        y = max_y - row

        cols = (0..max_x).map do |x|
          loc = Location.new(x, y)

          if path.include?(loc)
            after = path.index{ |l| l.as_json == loc.as_json} + 1

            if after >= path.size
              "\u00d7"
            elsif loc.as_json == path.first.as_json
              case loc.direction(path[after])
              when 'up'
                "\u21a5"
              when 'down'
                "\u21a7"
              when 'left'
                "\u21a4"
              when 'right'
                "\u21a6"
              end
            else
              case loc.direction(path[after])
              when 'up'
                "\u2191"
              when 'down'
                "\u2193"
              when 'left'
                "\u2190"
              when 'right'
                "\u2192"
              end
            end
          else
            'O'
          end
        end.join(' ')

        puts "#{prefix}  #{cols}"
      end
    end
  end
end