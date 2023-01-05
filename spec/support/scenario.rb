require 'json'
require 'digest/md5'

##
# A board can be represented as a shorthand string for easy definition.
#
#   Example:
#
#   ########F##
#   #####0#####
#   ###v#^#####
#   ###>>^#####
#   ###########
#   ###F#######
#   ###########
#   #########F#
#   ###########
#   ###########
#   ###########
#
#   - Blank spaces are represented by hashes, or any non-significant character.
#   - Numbers represent the head of a snake; 0 indicates "you".
#   - Pointer characters (^, v, <, >) point toward the head of the snake and show direction.
#   - F: food.
#   - H: hazard.


class Scenario
  attr_reader :string

  def initialize(string)
    @string = string
  end

  def to_json
    return @to_json if defined?(@to_json)

    json = {
      height: grid.first.size,
      width: grid.size,
      snakes: snakes,
      food: foods,
      hazards: hazards
    }

    @to_json = deep_transform_keys(json, &:to_s)
  end

  def to_board
    Battlesnake::Board.new(to_json)
  end

  def foods
    return @foods if defined?(@foods)

    @foods = coords_to_hashes(
      coords('F')
    )
  end

  def hazards
    return @hazards if defined?(@hazards)

    @hazards = coords_to_hashes(
      coords('H')
    )
  end

  def heads
    return @heads if defined?(@heads)
    @heads = (0..9).map(&:to_s).select{ |i| string.include?(i) }.map{ |i| coord(i) }
  end

  def snakes
    return @snakes if defined?(@snakes)
     @snakes = heads.map{ |head| body_for(head) }.map{ |coords| coords_to_snake(coords) }
  end

  private

  def coords_to_snake(coords, attributes = {})
    key = Digest::MD5.hexdigest(coords.to_json)[0, 24]
    body = coords_to_hashes(coords)

    json = {
      "id": "gs_#{key}",
      "name": "Name",
      "latency": "50",
      "health": 100,
      "body": body,
      "head": body.first,
      "length": body.size,
      "shout": "",
      "squad": "",
      "customizations": {
        "color": "#a51f02",
        "head": "beluga",
        "tail": "curled"
      }
    }.merge(attributes)

    deep_transform_keys(json, &:to_s)
  end

  def grid
    return @grid if defined?(@grid)

    list = string.split("\n").reverse.map do |line|
      line.strip.split('')
    end

    @grid = transpose(list)
  end

  def transpose(list)
    inverse = []

    list.each.with_index do |row, y|
      row.each.with_index do |char, x|
        inverse[x] ||= []
        inverse[x][y] = char
      end
    end

    inverse
  end

  def body_for(head, body = [])
    body += [head]
    x, y = head

    up = [x, y + 1]
    down = [x, y - 1]
    left = [x - 1, y]
    right = [x + 1, y]

    if char_at(*up) == 'v'
      body_for(up, body)
    elsif char_at(*down) == '^'
      body_for(down, body)
    elsif char_at(*left) == '>'
      body_for(left, body)
    elsif char_at(*right) == '<'
      body_for(right, body)
    else
      body
    end
  end

  def char_at(x, y)
    grid[x][y]
  end

  def coord(query)
    grid.each.with_index do |column, x|
      column.each.with_index do |char, y|
        return [x, y] if query == char
      end
    end

    nil
  end

  def coords(query)
    results = []

    grid.each.with_index do |column, x|
      column.each.with_index do |char, y|
        results << [x, y] if query == char
      end
    end

    results
  end

  def coord_to_hash(x, y)
    {
      'x' => x,
      'y' => y
    }
  end

  def coords_to_hashes(coords)
    coords.map{ |coord| coord_to_hash(*coord) }
  end

  def deep_transform_keys(structure, &block)
    case structure
    when Array
      structure.map{ |item| deep_transform_keys(item, &block) }
    when Hash
      structure.map{ |key, item| [block.call(key), deep_transform_keys(item, &block)] }.to_h
    else
      structure
    end
  end
end