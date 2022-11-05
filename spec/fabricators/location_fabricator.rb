require_relative '../../lib/battlesnake/location'

Fabricator(:location, class_name: 'Battlesnake::Location') do
  transient board_width: 11, board_height: 11

  initialize_with do |transients|
    payload = {
      'x' => transients[:x] || rand(transients[:board_width]),
      'y' => transients[:y] || rand(transients[:board_height])
    }

    resolved_class.new(payload)
  end
end
