require 'digest/md5'

require_relative '../../lib/battlesnake/snake'

Fabricator(:snake, class_name: 'Battlesnake::Snake') do
  transient :id, :name, :body, :head, :customizations, latency: '20', health: 100, length: 3, shout: '', squad: '', offset: 0

  initialize_with do |transients|
    payload = transients.transform_keys(&:to_s)

    payload['id'] ||= sequence_snake_id
    payload['name'] ||= sequence_snake_name
    payload['body'] ||= fabricate_snake_body(payload['length'], transients[:offset])
    payload['head'] ||= payload['body'].first
    payload['customizations'] ||= fabricate_snake_customization

    resolved_class.new(payload)
  end
end

def sequence_snake_id
  Fabricate.sequence(:snake_id){ |i| "gs_#{Digest::MD5.hexdigest(i.to_s)[0,24]}" }
end

def sequence_snake_name
  Fabricate.sequence(:snake_name){ |i| "Snake #{i}" }
end

def fabricate_snake_body(length, offset)
  board_max = 11

  board_max.times.map do |y|
    board_max.times.map{|x| y % 2 == 0 ? [x, y] : [board_max-x-1,y] }
  end.flatten.each_slice(2).map do |x, y|
    {'x' => x, 'y' => y}
  end[offset, length]
end

def fabricate_snake_customization
  heads = %w(beluga bendr bonhomme, caffeine default)
  tails = %w(block-bum bolt bonhomme coffee curled default do-sammy)

  {
    'color' => sprintf('#%02x%02x%02x', rand(256), rand(256), rand(256)),
    'head' => heads.shuffle.first,
    'tail' => tails.shuffle.first
  }
end

# an array of snakes whose bodies to not overlap
def fabricate_snake_group(count, length, occupied_locations = [])
  snakes = []
  occupied = occupied_locations
  offset = 0

  while snakes.size < count
    snake_attrs = Fabricate(:snake, length: length, offset: offset).as_json

    if (snake_attrs['body'] & occupied).empty?
      snakes << snake_attrs
      occupied += snake_attrs['body']
    end

    offset += length
  end

  snakes
end

