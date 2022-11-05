require_relative '../../lib/battlesnake/board'

Fabricator(:board, class_name: 'Battlesnake::Board') do
  transient width: 11, height: 11, snake_count: 3, food_count: 5, hazard_count: 1

  initialize_with do |transients|
    payload = transients.slice(:width, :height).transform_keys(&:to_s)

    occupied_locations = []

    payload['snakes'] = fabricate_snake_group(transients[:snake_count], 3, occupied_locations)
    occupied_locations += payload['snakes'].map{ |snake| snake['body'] }.flatten

    payload['food'] = fabricate_board_locations(transients[:food_count], occupied_locations)
    occupied_locations += payload['food']

    payload['hazards'] = fabricate_board_locations(transients[:hazard_count], occupied_locations)
    occupied_locations += payload['hazards']

    resolved_class.new(payload)
  end
end

def fabricate_board_locations(count, occupied_locations)
  locations = []
  occupied = occupied_locations

  while locations.size < count
    location = Fabricate(:location).as_json

    unless occupied.include?(location)
      locations << location
      occupied << location
    end
  end

  locations
end